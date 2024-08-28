package VCloudFunctions;

import com.vmware.vcloud.api.rest.schema.*;
import com.vmware.vcloud.sdk.*;
import com.vmware.vcloud.sdk.admin.extensions.VcloudAdminExtension;
import com.vmware.vcloud.sdk.constants.UndeployPowerActionType;
import com.vmware.vcloud.sdk.constants.Version;
import java.io.IOException;
import java.math.BigInteger;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.TimeoutException;
import java.util.logging.Level;
import org.apache.http.HttpException;

public class VCloudFunctions {

    public static VcloudClient vcloudClient;
    public static VcloudAdminExtension extension;
    public static String VCloudURL;
    public static String Username;
    public static String Password;

    public static void login() throws HttpException,
            VCloudException, IOException, KeyManagementException,
            NoSuchAlgorithmException, UnrecoverableKeyException,
            KeyStoreException, InterruptedException, TimeoutException {


        VcloudClient.setLogLevel(Level.OFF);

        vcloudClient = new VcloudClient(VCloudURL, Version.V1_5);

        vcloudClient.registerScheme("https", 443, FakeSSLSocketFactory.getInstance());

        try {
            vcloudClient.login(Username, Password);

        } catch (Exception e) {
            System.out.println("ERROR: Couldn't login to vcloud, please check your username, password and organization and try again");
            System.exit(1);
        }
        extension = vcloudClient.getVcloudAdminExtension();
    }

    public static void main(String args[]) throws HttpException,
            VCloudException, IOException, KeyManagementException,
            NoSuchAlgorithmException, UnrecoverableKeyException,
            KeyStoreException, InterruptedException, TimeoutException {

        if (args.length < 3) {
            System.exit(0);
        }

        // Client login details
        VCloudURL = args[0];
        Username = args[1];
        Password = args[2];
        // Login
        login();

        // Get the function name
        String function = args[3];
        switch (function) {
            case "getVMNameByIP":
                System.out.println(getVMNameByIP(args[4]));
                break;
            case "getVMsFromIP":
                System.out.println(getVMsFromIP(args[4]));
                break;
            case "get_vapp_id_by_gateway_ip":
                get_vapp_id_by_gateway_ip(args[4]);
                break;
            case "list_vms_in_vapp":
                list_vms_in_vapp(args[4]);
                break;
            case "list_vms_in_vapp_template":
                list_vms_in_vapp_template(args[4]);
                break;
            case "poweron_vm":
                poweron_vm(args[4]);
                break;
            case "poweroff_vm":
                poweroff_vm(args[4]);
                break;
            case "shutdown_vm":
                shutdown_vm(args[4]);
                break;
            case "reset_vm":
                reset_vm(args[4]);
                break;
            case "reboot_vm":
                reboot_vm(args[4]);
                break;
            case "suspend_vm":
                suspend_vm(args[4]);
                break;
            case "list_vapps_in_org":
                list_vapps_in_org(args[4]);
                break;
            case "list_vapp_templates_in_org":
                list_vapp_templates_in_org(args[4]);
                break;
            case "clone_vapp":
                clone_vapp(args[4], Boolean.parseBoolean(args[5]), args[6]);
                break;
            case "copy_vapp_template":
                copy_vapp_template(args[4], args[5], args[6]);
                break;
            case "getVdcIdFromName":
                System.out.println(getOrgVdcIdFromName(args[4]));
                break;
            case "deploy_from_catalog":
                deploy_from_catalog(args[4], args[5], args[6], Boolean.parseBoolean(args[7]));
                break;
            case "update_org_network_gateway":
                update_org_network_gateway(args[4]);
                break;
            case "reset_mac_gateway":
                reset_mac_gateway(args[4]);
                break;
            case "poweron_gateway":
                poweron_gateway(args[4]);
                break;
            case "list_nics_on_vm":
                list_nics_on_vm(args[4]);
                break;
            case "start_vapp":
                start_vapp(args[4]);
                break;
            case "stop_vapp":
                stop_vapp(args[4]);
                break;
            case "poweroff_vapp":
                poweroff_vapp(args[4]);
                break;
            case "shutdown_vapp":
                shutdown_vapp(args[4]);
                break;
            case "force_stop_vapp":
                force_stop_vapp(args[4]);
                break;
            case "suspend_vapp":
                suspend_vapp(args[4]);
                break;
            case "delete_vapp":
                delete_vapp(args[4]);
                break;
            case "delete_vapp_template":
                delete_vapp_template(args[4]);
                break;
            case "delete_vm":
                delete_vm(args[4]);
                break;
            case "get_catalog_of_vapp_template":
                get_catalog_of_vapp_template(args[4]);
                break;
            case "get_org_of_vapp_template":
                get_org_of_vapp_template(args[4]);
                break;
            case "get_orgvdc_of_vapp_template":
                get_orgvdc_of_vapp_template(args[4]);
                break;
            case "update_storage_lease_vapp":
                update_storage_lease_vapp(args[4], Integer.parseInt(args[5]));
                break;
            case "update_runtime_lease_vapp":
                update_runtime_lease_vapp(args[4], Integer.parseInt(args[5]));
                break;
            case "update_storage_lease_vapp_template":
                update_storage_lease_vapp_template(args[4], Integer.parseInt(args[5]));
                break;
            case "consolidate_vapp_template":
                consolidate_vapp_template(args[4]);
                break;
            case "consolidate_vapp":
                consolidate_vapp(args[4]);
                break;
            case "rename_vapp":
                rename_vapp(args[4], args[5]);
                break;
            case "rename_vapp_template":
                rename_vapp_template(args[4], args[5]);
                break;
            case "set_memory_vm":
                set_memory_vm(args[4], BigInteger.valueOf(Long.parseLong(args[5])));
                break;
            case "set_cpus_vm":
                set_cpus_vm(args[4], Integer.parseInt(args[5]));
                break;
            case "add_vapp_to_catalog":
                add_vapp_to_catalog(args[4], args[5], args[6]);
                break;
            default:
                System.out.println("ERROR: You didn't give a valid function name");
                System.exit(1);
                break;
        }

    }

    public static void delete_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);
        vapp.delete().waitForTask(0);
    }

    public static void delete_vapp_template(String vappTemplateId) throws VCloudException, TimeoutException {
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);
        vappTemplate.delete().waitForTask(0);
    }

    public static void delete_vm(String vmId) throws VCloudException, TimeoutException {
        VM vm = VM.getVMById(vcloudClient, vmId);
        vm.delete().waitForTask(0);
    }

    public static void update_storage_lease_vapp(String vappId, Integer storage) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        LeaseSettingsSectionType t = vapp.getLeaseSettingsSection();
        t.setStorageLeaseInSeconds(storage);
        vapp.updateSection(t).waitForTask(0);
    }

    public static void update_runtime_lease_vapp(String vappId, Integer runtime) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        LeaseSettingsSectionType t = vapp.getLeaseSettingsSection();
        t.setDeploymentLeaseInSeconds(runtime);
        vapp.updateSection(t).waitForTask(0);
    }

    public static void update_storage_lease_vapp_template(String vappTemplateId, Integer storage) throws VCloudException, TimeoutException {
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);

        LeaseSettingsSectionType t = vappTemplate.getLeaseSettingsSection();
        t.setStorageLeaseInSeconds(storage);
        vappTemplate.updateSection(t).waitForTask(0);
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
                        vm.getGuestCustomizationSection().getComputerName();
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

    public static void clone_vapp(String vappId, Boolean linkedclone, String newVappName) throws VCloudException, TimeoutException, InterruptedException {


        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);
        //System.out.println("Cloning vapp " + vappId + " " + vapp.getResource().getName());

        // Create params for the clone
        CloneVAppParamsType params = new CloneVAppParamsType();
        params.setDeploy(true);
        params.setDescription(vapp.getResource().getDescription());
        InstantiationParamsType p = new InstantiationParamsType();
        params.setInstantiationParams(p);
        params.setIsSourceDelete(false);
        params.setLinkedClone(linkedclone);
        params.setName(newVappName);
        params.setPowerOn(false);
        params.setSource(vapp.getReference());

        // Perform the clone
        Vapp newVapp = Vdc.getVdcByReference(vcloudClient, vapp.getVdcReference()).cloneVapp(params);
        for (Task task : newVapp.getTasks()) {
            //System.out.println("Waiting on create vapp clone task " + task.toString());
            task.waitForTask(0);
        }

        System.out.println("NEWVAPPID " + newVapp.getResource().getId());

    }

    public static void add_vapp_to_catalog(String vappId, String newVappTemplateName, String destinationCatalogName) throws VCloudException, TimeoutException {

        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        Catalog theCatalogRef = null;


        HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();
        out:
        for (ReferenceType orgRef : orgsList.values()) {
            //for (ReferenceType vdcRef : Organization.getOrganizationByReference(vcloudClient, orgRef).getVdcRefs()) {
            //Vdc vdc = Vdc.getVdcByReference(vcloudClient, vdcRef);

            //System.out.println("Vdc : " + vdcRef.getName() + " : " + vdc.getResource().getAllocationModel());
            //for (ReferenceType vAppRef : Vdc.getVdcByReference(vcloudClient, vdcRef).getVappRefs()) {

            Collection<ReferenceType> catalogRefs = Organization.getOrganizationByReference(vcloudClient, orgRef).getCatalogRefs();

            if (!catalogRefs.isEmpty()) {

                for (ReferenceType catalogRef : catalogRefs) {
                    if (catalogRef.getName().equals(destinationCatalogName)) {
                        Catalog catalog = Catalog.getCatalogByReference(vcloudClient, catalogRef);

                        theCatalogRef = catalog;
                        break out;
                    }

                }
            }
        }
        if (theCatalogRef == null) {
            System.out.println("ERROR: Couldn't find the destination catalog");
            System.exit(1);
        }

        // Capture the vapp

        CaptureVAppParamsType captureVappParamsType = new CaptureVAppParamsType();

        captureVappParamsType.setSource(vapp.getReference());
        captureVappParamsType.setName(newVappTemplateName);
        captureVappParamsType.setDescription(vapp.getResource().getDescription());

        VappTemplate newVappTemplate = Vdc.getVdcByReference(vcloudClient, vapp.getVdcReference()).captureVapp(captureVappParamsType);

        for (Task task : newVappTemplate.getTasks()) {
            task.waitForTask(0);
        }

        // Add it to the destination catalog
        CatalogItemType catalogItemType = new CatalogItemType();
        catalogItemType.setName(newVappTemplateName);
        catalogItemType.setDescription(vapp.getResource().getDescription());
        catalogItemType.setHref(newVappTemplate.getResource().getHref());
        catalogItemType.setEntity(newVappTemplate.getReference());

        CatalogItem catalogItem = theCatalogRef.addCatalogItem(catalogItemType);
        for (Task task : catalogItem.getTasks()) {

            task.waitForTask(0);
        }

        System.out.println("NEWVAPPTEMPLATEID " + newVappTemplate.getResource().getId());

    }

    public static void copy_vapp_template(String vappTemplateId, String newVappTemplateName, String destinationCatalogName) throws VCloudException, TimeoutException {

        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);

        Catalog theCatalogRef = null;

        if (destinationCatalogName.equals("same")) {
            Organization vappOrg = Organization.getOrganizationByReference(vcloudClient, Vdc.getVdcByReference(vcloudClient, vappTemplate.getVdcReference()).getOrgReference());
            Collection<ReferenceType> catalogRefs = vappOrg.getCatalogRefs();

            out:
            if (!catalogRefs.isEmpty()) {

                for (ReferenceType catalogRef : catalogRefs) {

                    Catalog catalog = Catalog.getCatalogByReference(vcloudClient, catalogRef);

                    for (ReferenceType catalogItemReference : catalog.getCatalogItemReferences()) {

                        if (catalogItemReference.getHref().equals(vappTemplate.getCatalogItemReference().getHref())) {

                            theCatalogRef = catalog;
                            break out;
                        }
                    }

                }
                //System.out.println();

            } else {
                System.out.println("No Catalogs Found");
                System.exit(1);
            }
        } else {

            HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();
            out:
            for (ReferenceType orgRef : orgsList.values()) {

                Collection<ReferenceType> catalogRefs = Organization.getOrganizationByReference(vcloudClient, orgRef).getCatalogRefs();

                if (!catalogRefs.isEmpty()) {

                    for (ReferenceType catalogRef : catalogRefs) {
                        if (catalogRef.getName().equals(destinationCatalogName)) {
                            Catalog catalog = Catalog.getCatalogByReference(vcloudClient, catalogRef);

                            theCatalogRef = catalog;
                            break out;
                        }

                    }
                }
            }
        }
        if (theCatalogRef == null) {
            System.out.println("ERROR: Couldn't find the destination catalog");
            System.exit(1);
        }


        //System.out.println("Cloning vapp template " + vappTemplateId + " " + vappTemplate.getResource().getName());

        // Create params for the clone
        CloneVAppTemplateParamsType params = new CloneVAppTemplateParamsType();

        params.setDescription(vappTemplate.getResource().getDescription());
        params.setIsSourceDelete(false);
        params.setName(newVappTemplateName);
        params.setSource(vappTemplate.getReference());

        // Perform the clone
        VappTemplate newVappTemplate = Vdc.getVdcByReference(vcloudClient, vappTemplate.getVdcReference()).cloneVappTemplate(params);
        for (Task task : newVappTemplate.getTasks()) {
            //System.out.println("Waiting on create vapp template clone task " + task.toString());
            task.waitForTask(0);
        }

        // Add the clone to the same catalog
        CatalogItemType catalogItemType = new CatalogItemType();

        catalogItemType.setName(newVappTemplateName);
        catalogItemType.setDescription(vappTemplate.getResource().getDescription());
        catalogItemType.setHref(newVappTemplate.getReference().getHref());
        catalogItemType.setEntity(newVappTemplate.getReference());
        CatalogItem catalogItem = theCatalogRef.addCatalogItem(catalogItemType);

        for (Task task : catalogItem.getTasks()) {
            //System.out.println("Waiting on add to catalog task " + task.toString());
            task.waitForTask(0);
        }
        System.out.println("NEWVAPPTEMPLATEID " + newVappTemplate.getResource().getId());

    }

    public static String getOrgVdcIdFromName(String orgVdcName) throws VCloudException {
        HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();
        for (ReferenceType orgRef : orgsList.values()) {
            for (ReferenceType vdcRef : Organization.getOrganizationByReference(vcloudClient, orgRef).getVdcRefs()) {

                if (vdcRef.getName().equals(orgVdcName)) {
                    return Vdc.getVdcByReference(vcloudClient, vdcRef).getResource().getId();
                }
            }
        }
        return "";
    }

    public static void deploy_from_catalog(String orgVdcName, String vappTemplateId, String vappName, Boolean linkedclone) throws VCloudException, TimeoutException {

        String orgVdcId = getOrgVdcIdFromName(orgVdcName);
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);
        ReferenceType vappTemplateReference = vappTemplate.getReference();


        InstantiateVAppTemplateParamsType params = new InstantiateVAppTemplateParamsType();

        params.setDeploy(false);
        params.setDescription(vappTemplate.getResource().getDescription());
        params.setIsSourceDelete(false);
        params.setLinkedClone(linkedclone);
        params.setName(vappName);
        params.setPowerOn(false);
        params.setSource(vappTemplateReference);

        Vapp newVapp = Vdc.getVdcById(vcloudClient, orgVdcId).instantiateVappTemplate(params);
        for (Task task : newVapp.getTasks()) {
            task.waitForTask(0);
        }
        String vappId = Vapp.getVappByReference(vcloudClient, newVapp.getReference()).getResource().getId();
        System.out.println("NEWVAPPID " + vappId);

    }

    public static void update_org_network_gateway(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);
        List<VM> vms;
        NetworkConnectionType t;
        OrgNetwork orgNetwork = null;
        for (ReferenceType orgNetworkReference : Vdc.getVdcByReference(vcloudClient, vapp.getVdcReference()).getAvailableNetworkRefs()) {
            orgNetwork = OrgNetwork.getOrgNetworkByReference(vcloudClient, orgNetworkReference);
            break;
        }

        vms = vapp.getChildrenVms();

        for (VM vm : vms) {

            if (vm.getResource().getName().contains("gateway")) {

                NetworkConnectionSectionType networkConnectionSection = vm.getNetworkConnectionSection();
                Iterator iterator = networkConnectionSection.getNetworkConnection().iterator();

                while (iterator.hasNext()) {

                    t = (NetworkConnectionType) iterator.next();

                    if (!t.getMACAddress().contains("00:50:56:00")) {
                        //System.out.println("Setting the org network to be " + orgNetwork.getResource().getName());
                        t.setNetwork(orgNetwork.getResource().getName());
                        t.setIpAddressAllocationMode("DHCP");
                        t.setIsConnected(true);
                        vm.updateSection(networkConnectionSection).waitForTask(0);
                        return;
                    }
                }
            }
        }
    }

    public static void reset_mac_gateway(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);
        List<VM> vms;
        NetworkConnectionType t;

        vms = vapp.getChildrenVms();
        for (VM vm : vms) {

            if (vm.getResource().getName().contains("gateway")) {

                NetworkConnectionSectionType networkConnectionSection = vm.getNetworkConnectionSection();
                Iterator iterator = networkConnectionSection.getNetworkConnection().iterator();

                while (iterator.hasNext()) {

                    t = (NetworkConnectionType) iterator.next();

                    if (!t.getMACAddress().contains("00:50:56:00")) {
                        //System.out.println("Resetting mac for network connected to " + t.getNetwork());
                        t.setMACAddress(null);

                        vm.updateSection(networkConnectionSection).waitForTask(0);
                        return;
                    }
                }
            }

        }

    }

    public static void poweron_gateway(String vappId) throws VCloudException, TimeoutException, InterruptedException, KeyManagementException, UnrecoverableKeyException, NoSuchAlgorithmException, KeyStoreException, HttpException, IOException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);
        List<VM> vms;
        NetworkConnectionType t;

        vms = vapp.getChildrenVms();
        for (VM vm : vms) {

            if (vm.getResource().getName().contains("gateway")) {
                //System.out.println("Powering on the gateway " + vm.getResource().getId());
                vm.powerOn().waitForTask(0);
            }
        }

        //System.out.println("Waiting for it to get an IP Address");
        int i = 0;
        while (i < 600) {
            login();

            vapp = Vapp.getVappById(vcloudClient, vappId);
            vms = vapp.getChildrenVms();
            for (VM vm : vms) {

                if (vm.getResource().getName().contains("gateway")) {

                    Iterator iterator = vm.getNetworkConnections().iterator();

                    while (iterator.hasNext()) {
                        t = (NetworkConnectionType) iterator.next();

                        if (!t.getMACAddress().contains("00:50:56:00")) {

                            if (t.getIpAddress() != null) {
                                System.out.println("IPADDRESS " + t.getIpAddress());

                                return;
                            }
                        }
                    }

                }

            }
            Thread.sleep(1000);
            i++;
        }
        System.out.println("ERROR: Couldn't seem to get the ip address of the gateway after powering it on, please check why");
        System.exit(1);

    }

    public static void get_org_of_vapp_template(String vappTemplateId) throws VCloudException, TimeoutException, InterruptedException, KeyManagementException, UnrecoverableKeyException, NoSuchAlgorithmException, KeyStoreException, HttpException, IOException {
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);
        Organization organization = Organization.getOrganizationByReference(vcloudClient, Vdc.getVdcByReference(vcloudClient, vappTemplate.getVdcReference()).getOrgReference());
        System.out.println(organization.getResource().getName());

    }

    public static void get_orgvdc_of_vapp_template(String vappTemplateId) throws VCloudException, TimeoutException, InterruptedException, KeyManagementException, UnrecoverableKeyException, NoSuchAlgorithmException, KeyStoreException, HttpException, IOException {
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);
        Vdc orgvdc = Vdc.getVdcByReference(vcloudClient, vappTemplate.getVdcReference());
        System.out.println(orgvdc.getResource().getName());

    }

    public static void get_catalog_of_vapp_template(String vappTemplateId) throws VCloudException, TimeoutException, InterruptedException, KeyManagementException, UnrecoverableKeyException, NoSuchAlgorithmException, KeyStoreException, HttpException, IOException {
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);
        CatalogItem catalogItem = CatalogItem.getCatalogItemByReference(vcloudClient, vappTemplate.getCatalogItemReference());

        System.out.println(Catalog.getCatalogByReference(vcloudClient, catalogItem.getCatalogReference()).getResource().getName());

    }

    public static void list_nics_on_vm(String vmId) throws VCloudException, TimeoutException, InterruptedException, KeyManagementException, UnrecoverableKeyException, NoSuchAlgorithmException, KeyStoreException, HttpException, IOException {
        VM vm = VM.getVMById(vcloudClient, vmId);

        NetworkConnectionType t;

        Iterator iterator = vm.getNetworkConnections().iterator();
        String ipaddress;
        while (iterator.hasNext()) {
            t = (NetworkConnectionType) iterator.next();
            ipaddress = t.getIpAddress();
            if (ipaddress == null) {
                ipaddress = "";
            }

            System.out.println(t.getNetworkConnectionIndex() + ";" + t.isIsConnected() + ";" + t.getNetwork() + ";" + t.getIpAddressAllocationMode() + ";" + ipaddress + ";" + t.getMACAddress());

        }

    }

    public static void start_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        vapp.deploy(true, vapp.getLeaseSettingsSection().getDeploymentLeaseInSeconds(), false).waitForTask(0);

    }

    public static void stop_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        vapp.undeploy(UndeployPowerActionType.DEFAULT).waitForTask(0);

    }

    public static void poweroff_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        vapp.undeploy(UndeployPowerActionType.POWEROFF).waitForTask(0);

    }

    public static void shutdown_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        vapp.undeploy(UndeployPowerActionType.SHUTDOWN).waitForTask(0);

    }

    public static void force_stop_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        vapp.undeploy(UndeployPowerActionType.FORCE).waitForTask(0);

    }

    public static void suspend_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        vapp.undeploy(UndeployPowerActionType.SUSPEND).waitForTask(0);

    }

    public static void rename_vapp(String vappId, String newName) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);
        VAppType vappSettings = vapp.getResource();

        vappSettings.setName(newName);

        vapp.updateVapp(vappSettings).waitForTask(0);

    }

    public static void rename_vapp_template(String vappTemplateId, String newName) throws VCloudException, TimeoutException {
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);
        VAppTemplateType vappTemplateSettings = vappTemplate.getResource();

        vappTemplateSettings.setName(newName);

        vappTemplate.updateVappTemplate(vappTemplateSettings).waitForTask(0);
    }

    public static void set_memory_vm(String vmId, BigInteger ramSize) throws VCloudException, TimeoutException {
        VM vm = VM.getVMById(vcloudClient, vmId);
        VirtualMemory memory = vm.getMemory();
        memory.setMemorySize(ramSize);
        vm.updateMemory(memory).waitForTask(0);
    }

    public static void set_cpus_vm(String vmId, int cpuCount) throws VCloudException, TimeoutException {
        VM vm = VM.getVMById(vcloudClient, vmId);
        VirtualCpu cpu = vm.getCpu();
        cpu.setNoOfCpus(cpuCount);
        vm.updateCpu(cpu).waitForTask(0);
    }

    public static void consolidate_vapp(String vappId) throws VCloudException, TimeoutException {
        Vapp vapp = Vapp.getVappById(vcloudClient, vappId);

        List<VM> vms = vapp.getChildrenVms();
        for (VM vm : vms) {
            vm.consolidate().waitForTask(0);

        }
    }

    public static void consolidate_vapp_template(String vappTemplateId) throws VCloudException, TimeoutException {
        VappTemplate vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);

        List<VappTemplate> vms;
        vms = vappTemplate.getChildren();

        for (VappTemplate vminternal : vms) {
            if (vminternal.isVm()) {
                vminternal.consolidate().waitForTask(0);;
            }
        }

    }

    public static void list_vapps_in_org(String orgname) throws VCloudException {

        Vapp vapp;
        VappTemplate vappTemplate;
        HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();

        //VMWDatastore datastore = VMWDatastore.getVMWDatastoreById(vcloudClient, "urn:vcloud:datastore:4f9ac1a6-b9ed3d87-b6ed-d4856448ebe1");
        //output = datastore.getResource().getName();

        for (ReferenceType orgRef : orgsList.values()) {
            if (orgRef.getName().equals(orgname)) {
                // return orgRef.getName();

                System.out.println(orgRef.getName());
                for (ReferenceType vdcRef : Organization.getOrganizationByReference(vcloudClient, orgRef).getVdcRefs()) {
                    //Vdc vdc = Vdc.getVdcByReference(vcloudClient, vdcRef);
                    System.out.println(vdcRef.getName());
                    //System.out.println("Vdc : " + vdcRef.getName() + " : " + vdc.getResource().getAllocationModel());
                    for (ReferenceType vAppRef : Vdc.getVdcByReference(vcloudClient, vdcRef).getVappRefs()) {

                        vapp = Vapp.getVappByReference(vcloudClient, vAppRef);
                        System.out.print(vapp.getResource().getName() + ";" + vapp.getResource().getId());
                        System.out.println(";" + vapp.getVappStatus().name());

                    }

                }
                return;
            }

        }
        System.out.println("ERROR: There was no org of that name found");
        System.exit(1);
    }

    public static void list_vapp_templates_in_org(String orgname) throws VCloudException {

        Vapp vapp;
        VappTemplate vappTemplate;
        HashMap<String, ReferenceType> orgsList = vcloudClient.getOrgRefsByName();

        //VMWDatastore datastore = VMWDatastore.getVMWDatastoreById(vcloudClient, "urn:vcloud:datastore:4f9ac1a6-b9ed3d87-b6ed-d4856448ebe1");
        //output = datastore.getResource().getName();

        for (ReferenceType orgRef : orgsList.values()) {
            if (orgRef.getName().equals(orgname)) {
                // return orgRef.getName();

                System.out.println(orgRef.getName());
                for (ReferenceType vdcRef : Organization.getOrganizationByReference(vcloudClient, orgRef).getVdcRefs()) {
                    //Vdc vdc = Vdc.getVdcByReference(vcloudClient, vdcRef);
                    System.out.println(vdcRef.getName());
                    //System.out.println("Vdc : " + vdcRef.getName() + " : " + vdc.getResource().getAllocationModel());

                    for (ReferenceType vAppRef : Vdc.getVdcByReference(vcloudClient, vdcRef).getVappTemplateRefs()) {

                        vappTemplate = VappTemplate.getVappTemplateByReference(vcloudClient, vAppRef);
                        System.out.println(vappTemplate.getResource().getName() + ";" + vappTemplate.getResource().getId());
                    }

                }
                return;
            }

        }
        System.out.println("ERROR: There was no org of that name found");
        System.exit(1);
    }

    public static void get_vapp_id_by_gateway_ip(String ipinput) throws
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
                                    System.out.println("VAPPID " + vappID);
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
        System.exit(1);
    }

    public static void list_vms_in_vapp(String vappId) throws VCloudException {
        Vapp vapp;
        List<VM> vms;
        vapp = Vapp.getVappById(vcloudClient, vappId);
        vms = vapp.getChildrenVms();
        String vmname;
        String vmid;
        String vmid_short;

        for (VM vminternal : vms) {

            vmid_short = vminternal.getGuestCustomizationSection().getVirtualMachineId();
            vmname = vminternal.getResource().getName();
            vmid = vminternal.getResource().getId();

            System.out.print(vmname + ";");
            System.out.print(vmname + " (" + vmid_short + ");");
            System.out.println(vmid);

        }

    }

    public static void list_vms_in_vapp_template(String vappTemplateId) throws VCloudException {

        VappTemplate vappTemplate;
        List<VappTemplate> vms;
        vappTemplate = VappTemplate.getVappTemplateById(vcloudClient, vappTemplateId);
        vms = vappTemplate.getChildren();

        String vmname;
        String vmid;
        String vmid_short;

        for (VappTemplate vminternal : vms) {
            if (vminternal.isVm()) {
                vmid_short = vminternal.getGuestCustomizationSection().getVirtualMachineId();
                vmname = vminternal.getResource().getName();
                vmid = vminternal.getResource().getId();

                System.out.print(vmname + ";");
                System.out.print(vmname + " (" + vmid_short + ");");
                System.out.println(vmid);
            }
        }

    }

    public static void poweron_vm(String vmId) throws
            VCloudException, TimeoutException {

        VM.getVMById(vcloudClient, vmId).powerOn().waitForTask(0);
    }

    public static void poweroff_vm(String vmId) throws
            VCloudException, TimeoutException {
        VM.getVMById(vcloudClient, vmId).powerOff().waitForTask(0);

    }

    public static void shutdown_vm(String vmId) throws
            VCloudException, TimeoutException {
        VM.getVMById(vcloudClient, vmId).shutdown().waitForTask(0);

    }

    public static void reset_vm(String vmId) throws
            VCloudException, TimeoutException {
        VM.getVMById(vcloudClient, vmId).reset().waitForTask(0);
        //VM.getVMById(vcloudClient, "urn:vcloud:vm:" + input.split(" ")[1].replace("(", "").replace(")", "")).reset().waitForTask(0);
    }

    public static void suspend_vm(String vmId) throws
            VCloudException, TimeoutException {
        VM.getVMById(vcloudClient, vmId).suspend().waitForTask(0);
    }

    public static void reboot_vm(String vmId) throws
            VCloudException, TimeoutException {
        VM.getVMById(vcloudClient, vmId).reboot().waitForTask(0);
    }
}
