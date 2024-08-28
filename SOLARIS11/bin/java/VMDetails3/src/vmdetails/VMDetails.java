/*
 * *******************************************************
 * Copyright VMware, Inc. 2010-2011.  All Rights Reserved.
 * *******************************************************
 *
 * DISCLAIMER. THIS PROGRAM IS PROVIDED TO YOU "AS IS" WITHOUT
 * WARRANTIES OR CONDITIONS # OF ANY KIND, WHETHER ORAL OR WRITTEN,
 * EXPRESS OR IMPLIED. THE AUTHOR SPECIFICALLY # DISCLAIMS ANY IMPLIED
 * WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY # QUALITY,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
 */
package vmdetails;

import java.util.concurrent.TimeoutException;
import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.HashMap;
import java.util.List;
import java.util.logging.Level;
import java.util.Iterator;
import com.vmware.vcloud.api.rest.schema.*;
//import java.util.Collections;

import org.apache.http.HttpException;

import com.vmware.vcloud.api.rest.schema.ReferenceType;
import com.vmware.vcloud.sdk.Organization;
import com.vmware.vcloud.sdk.VCloudException;
import com.vmware.vcloud.sdk.VM;
import com.vmware.vcloud.sdk.Vapp;
import com.vmware.vcloud.sdk.VcloudClient;
import com.vmware.vcloud.sdk.Vdc;
//import com.vmware.vcloud.sdk.VirtualDisk;
//import com.vmware.vcloud.sdk.*;
import com.vmware.vcloud.sdk.constants.Version;

/*
 * This sample lists all the vdc's (Name, Allocation Model), vapp's (Name) and
 * its vms (Name, Status, Cpu, Memory & HardDisks).
 *
 */
public class VMDetails {

    public static VcloudClient vcloudClient;

    public static void main(String args[]) throws HttpException,
            VCloudException, IOException, KeyManagementException,
            NoSuchAlgorithmException, UnrecoverableKeyException,
            KeyStoreException, InterruptedException, TimeoutException {

        if (args.length < 4) {
            System.out.println("java VMDetails vCloudURL user@organization password");
            System.out.println("java VMDetails https://vcloud user@System password");
            System.exit(0);
        }
        String function = args[3];
        //System.out.println(function);
        // Client login
        VcloudClient.setLogLevel(Level.OFF);
        vcloudClient = new VcloudClient(args[0], Version.V1_5);
        vcloudClient.registerScheme("https", 443, FakeSSLSocketFactory.getInstance());
        vcloudClient.login(args[1], args[2]);

        if (function.equals("getVMNameByIP")) {
            System.out.println(getVMNameByIP(args[4]));
        }
        if (function.equals("getVMsFromIP")) {
            System.out.println(getVMsFromIP(args[4]));
        }
        if (function.equals("getVappIDGateway")) {
            System.out.println(getVappIDGateway(args[4]));
        }
        if (function.equals("getVMsByVAPP")) {
            System.out.println(getVMsByVAPP(args[4]));
        }
        if (function.equals("poweronvm")) {
            poweronvm(args[4]);
        }
        if (function.equals("poweroffvm")) {
            poweroffvm(args[4]);
        }
        if (function.equals("resetvm")) {
            resetvm(args[4]);
        }
        //System.out.println(getVMNameByIP(args[4]));
        //System.out.println(getVMsFromIP(args[4]));
        //System.out.println(getVappIDGateway());
        //System.out.println(getVMsByVAPP("urn:vcloud:vapp:23747245-09f6-48d4-bf62-d2a42bbf5996"));

    }

    public static String getVMNameByIP(String ipinput) throws HttpException,
            VCloudException, IOException, KeyManagementException,
            NoSuchAlgorithmException, UnrecoverableKeyException,
            KeyStoreException {
        List<VM> vms;
        Vapp vapp;
        HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();
        for (ReferenceType orgRef : orgsList.values()) {
            for (ReferenceType vdcRef : Organization.getOrganizationByReference(vcloudClient, orgRef).getVdcRefs()) {

                //Vdc vdc = Vdc.getVdcByReference(vcloudClient, vdcRef);
                //System.out.println("Vdc : " + vdcRef.getName() + " : " + vdc.getResource().getAllocationModel());
                for (ReferenceType vAppRef : Vdc.getVdcByReference(
                        vcloudClient, vdcRef).getVappRefs()) {
                    //System.out.println("	Vapp : " + vAppRef.getName());
                    vapp = Vapp.getVappByReference(vcloudClient, vAppRef);

                    vms = vapp.getChildrenVms();
                    for (VM vm : vms) {
                        //System.out.println("		Vm : " + vm.getResource().getName());
                        //System.out.println("			Status : " + vm.getVMStatus());
                        //System.out.println("			CPU : " + vm.getCpu().getNoOfCpus());

                        //System.out.println("			Memory : " + vm.getMemory().getMemorySize() + " Mb");
                        //for (VirtualDisk disk : vm.getDisks()) {
                        //    if (disk.isHardDisk()) {
                        //System.out.println("			HardDisk : " + disk.getHardDiskSize() + " Mb");
                        //   }
                        //}

                        //System.out.println(vm.getGuestCustomizationSection().getVirtualMachineId());
                        Iterator iterator = vm.getNetworkConnections().iterator();

                        while (iterator.hasNext()) {
                            NetworkConnectionType t = (NetworkConnectionType) iterator.next();

                            if (t.getIpAddress() != null && t.getIpAddress().equals(ipinput)) {
                                //System.out.println("Internal: " + t.getIpAddress());

                                return vm.getResource().getName() + " (" + vm.getGuestCustomizationSection().getVirtualMachineId() + ")";

                            }
                        }
                    }
                }
            }
        }
        return "";
    }

    public static String getVMsFromIP(String ipinput) throws
            VCloudException {
        String vm_list = new String("");
        String IPAddress = new String("");
        Vapp vapp;
        List<VM> vms;
        NetworkConnectionType t;
        HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();
        for (ReferenceType orgRef : orgsList.values()) {
            for (ReferenceType vdcRef : Organization.getOrganizationByReference(vcloudClient, orgRef).getVdcRefs()) {
                //Vdc vdc = Vdc.getVdcByReference(vcloudClient, vdcRef);
                //System.out.println("Vdc : " + vdcRef.getName() + " : " + vdc.getResource().getAllocationModel());
                for (ReferenceType vAppRef : Vdc.getVdcByReference(
                        vcloudClient, vdcRef).getVappRefs()) {
                    //System.out.println("	Vapp : " + vAppRef.getName());
                    vapp = Vapp.getVappByReference(vcloudClient, vAppRef);

                    vms = vapp.getChildrenVms();
                    for (VM vm : vms) {
                        //System.out.println("		Vm : " + vm.getResource().getName());
                        //System.out.println("			Status : " + vm.getVMStatus());
                        //System.out.println("			CPU : " + vm.getCpu().getNoOfCpus());

                        //System.out.println("			Memory : " + vm.getMemory().getMemorySize() + " Mb");
                        //for (VirtualDisk disk : vm.getDisks()) {
                        //    if (disk.isHardDisk()) {
                        //System.out.println("			HardDisk : " + disk.getHardDiskSize() + " Mb");
                        //   }
                        //}

                        //System.out.println(vm.getGuestCustomizationSection().getVirtualMachineId());

                        Iterator iterator = vm.getNetworkConnections().iterator();

                        while (iterator.hasNext()) {
                            t = (NetworkConnectionType) iterator.next();
                            IPAddress = t.getIpAddress();
                            if (IPAddress != null && IPAddress.equals(ipinput)) {
                                //System.out.println("Internal: " + t.getIpAddress());

                                for (VM vminternal : vms) {
                                    vm_list = vm_list + vminternal.getResource().getName() + " (" + vminternal.getGuestCustomizationSection().getVirtualMachineId() + ")" + "\n";
                                    //if (vminternal.getResource().getName().contains("uas1")) {
                                    //    System.out.println("UAS is " + vminternal.getResource().getName());
                                    //Task ta = vminternal.reset();
                                    //vminternal.installVMwareTools().
                                    //ta.wait();
                                    //vminternal.installVMwareTools();
                                    //    List myl=Collections.emptyList();;
                                    //    vminternal.updateSerialPorts(myl);

                                    //    System.out.println("Done");
                                    //}
                                    //for (SerialPort sp : vminternal.getSerialPorts()) {
                                    //    System.out.println(":" + sp.getSerialPortConfig().toString());
                                    //}
                                }

                                return vm_list;

                            }


                        }


                    }

                }
            }
        }
        return "";
    }

    public static String getVappIDGateway(String ipinput) throws
            VCloudException {
        String vm_list = new String("");
        String IPAddress = new String("");
        Vapp vapp;
        List<VM> vms;
        NetworkConnectionType t;
        HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();

        for (ReferenceType orgRef : orgsList.values()) {
            for (ReferenceType vdcRef : Organization.getOrganizationByReference(vcloudClient, orgRef).getVdcRefs()) {

                for (ReferenceType vAppRef : Vdc.getVdcByReference(
                        vcloudClient, vdcRef).getVappRefs()) {

                    vapp = Vapp.getVappByReference(vcloudClient, vAppRef);

                    vms = vapp.getChildrenVms();
                    for (VM vm : vms) {
                        if (vm.getResource().getName().contains("gateway")) {

                            Iterator iterator = vm.getNetworkConnections().iterator();

                            while (iterator.hasNext()) {
                                t = (NetworkConnectionType) iterator.next();
                                IPAddress = t.getIpAddress();
                                if (IPAddress != null && IPAddress.equals(ipinput)) {
                                    String vappID = vapp.getResource().getId();
                                    //vm_list = vm_list + vappID + " " + IPAddress + "\n";
                                    return vappID;
                                }
                            }


                        }


                    }

                }
            }
        }
        return "";
    }

    public static String getVMsByVAPP(String input) throws
            VCloudException {
        String vm_list = new String("");
        Vapp vapp;
        List<VM> vms;
        vapp = Vapp.getVappById(vcloudClient, input);
        vms = vapp.getChildrenVms();

        for (VM vminternal : vms) {
            vm_list = vm_list + vminternal.getResource().getName() + " (" + vminternal.getGuestCustomizationSection().getVirtualMachineId() + ")" + "\n";
        }
        return vm_list;
    }

    public static void poweronvm(String input) throws
            VCloudException ,TimeoutException{

        
        VM.getVMById(vcloudClient, "urn:vcloud:vm:" + input.split(" ")[1].replace("(", "").replace(")", "")).powerOn().waitForTask(300000);

    }

    public static void poweroffvm(String input) throws
            VCloudException , TimeoutException {
        VM.getVMById(vcloudClient, "urn:vcloud:vm:" + input.split(" ")[1].replace("(", "").replace(")", "")).powerOff().waitForTask(300000);

    }

    public static void resetvm(String input) throws
            VCloudException , TimeoutException {
        VM.getVMById(vcloudClient, "urn:vcloud:vm:" + input.split(" ")[1].replace("(", "").replace(")", "")).reset().waitForTask(300000);

    }
}