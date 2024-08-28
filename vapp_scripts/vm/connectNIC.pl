#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VIRuntime;
use VMware::VILib;

use Data::Dumper;

sub getStatus {
        my ($taskRef) = @_;

        my $task_view = Vim::get_view(mo_ref => $taskRef);
        my $taskinfo = $task_view->info->state->val;
        my $continue = 1;
        while ($continue) {
                my $info = $task_view->info;
                if ($info->state->val eq 'success') {
                        $continue = 0;
                } elsif ($info->state->val eq 'error') {
                        my $soap_fault = SoapFault->new;
                        $soap_fault->name($info->error->fault);
                        $soap_fault->detail($info->error->fault);
                        $soap_fault->fault_string($info->error->localizedMessage);
                        die "$soap_fault\n";
                }
                sleep 1;
                $task_view->ViewBase::update_view_data();
        }
}

sub main() {
    my %opts = 
	(
	 'vmname' => 
	 {
	     type => "=s",
	     help => "The name of the virtual machine",
	     required => 1,
	 },
	 
        'vnic' => {
	        type => "=n",
        	help => "vNIC Adapter # (e.g. 1,2,3,etc)",
	        required => 1,
        },

	 'pg' => {
	     type => "=s",
	     help => "The name of the portgroup to connect the NIC to",
	     required => 1,
	 },
	 'connected' => {
	     type => "=s",
	     help => "The connection state (true|false)",
	     required => 0,
	 }
	);
    
    # validate options, and connect to the server
    Opts::add_options(%opts);

    # validate options, and connect to the server
    Opts::parse();
    Opts::validate();
    Util::connect();

    my $vmname = Opts::get_option ('vmname');
    my $pgName = Opts::get_option ('pg');
    my $vnic = Opts::get_option ('vnic');

    my $connectedStr = Opts::get_option ('connected');
    my $connected = 1;
    if ( (defined $connectedStr) && ($connectedStr eq 'false') ) {
	$connected = 0;
    }

    my $vm_view = 
	Vim::find_entity_view(view_type => 'VirtualMachine', filter =>{ 'name' => $vmname});
    if ( ! $vm_view ) {
	print "Unable to locate $vmname!\n";
	exit 1;
    }

    my $devices = $vm_view->config->hardware->device;

    my $vnic_name = "Network adapter $vnic";
    my $vnic_device = undef;
    foreach my $device (@$devices) {
	if ($device->deviceInfo->label eq $vnic_name){
	    $vnic_device=$device;
	}
    }
    if ( ! defined $vnic_device ) { 
	Util::disconnect();
	print "ERROR: Unable to locate $vnic_name\n";
	exit 2;
    }

    my $backing_info;

    my $switchName;
    if ( $pgName =~ /([^\/]+)\/(.*)/ ) {
	( $switchName, $pgName ) = ( $1, $2 );
    }
    
    my $dpg_view;
    my $dpg_views = 
	Vim::find_entity_views(view_type => 'DistributedVirtualPortgroup', filter =>{ 'name' => $pgName});
    if ( $dpg_views && $#{$dpg_views} > -1 ) {
	if ( $switchName ) {
	    foreach my $view ( @{$dpg_views} ) {
		my $dvs_view = Vim::get_view(mo_ref => $view->config->distributedVirtualSwitch);
		if ( $dvs_view->{'name'} eq $switchName ) {
		    $dpg_view = $view;
		}
	    }
	} else {	    
	    my $dvs_view = Vim::get_view(mo_ref => $dpg_views->[0]->{'config'}->distributedVirtualSwitch);
	    print "Using DistributedVirtualPortgroup in ". $dvs_view->{'name'} . "\n";
	    $dpg_view = $dpg_views->[0];
	}
    }

    if ( $dpg_view ) {
	my $dvSwitch_view = Vim::get_view(mo_ref => $dpg_view->{'config'}->{'distributedVirtualSwitch'});

	my $dvspc = DistributedVirtualSwitchPortConnection->new(portgroupKey => $dpg_view->{key}, 
								switchUuid => $dvSwitch_view->{uuid});
	$backing_info = VirtualEthernetCardDistributedVirtualPortBackingInfo->new(port => $dvspc);
    } else {
	my $net_view = 
	    Vim::find_entity_view(view_type => 'Network', filter =>{ 'name' => $pgName});
	if ( ! $net_view ) {
	    print "ERROR: Could not find $pgName\n";
	    Util::disconnect();
	    exit 3;
	}	   
	$backing_info = VirtualEthernetCardNetworkBackingInfo->new(deviceName => $pgName);
    }

    my $newNetworkDevice;
    my $nictype = ref($vnic_device);
    
    if($nictype eq 'VirtualE1000') {
	$newNetworkDevice = VirtualE1000->new();
    } elsif($nictype eq 'VirtualPCNet32') {
	$newNetworkDevice = VirtualPCNet32->new();
    } elsif($nictype eq 'VirtualVmxnet2') {
	$newNetworkDevice = VirtualVmxnet2->new();
    } elsif($nictype eq 'VirtualVmxnet3') {
	$newNetworkDevice = VirtualVmxnet3->new();
    } else {
	Util::disconnect();
	die "Unable to retrieve nictype!\n";
    }

    $newNetworkDevice->{key} = $vnic_device->key;
    $newNetworkDevice->{unitNumber} = $vnic_device->unitNumber;
    $newNetworkDevice->{controllerKey} = $vnic_device->controllerKey;
    $newNetworkDevice->{backing} = $backing_info;
    $newNetworkDevice->{addressType} = $vnic_device->addressType;
    if ( ($vnic_device->addressType eq 'Manual') || ($vnic_device->addressType eq 'manual') ) { 
	$newNetworkDevice->{macAddress} = $vnic_device->macAddress;
    }

    if ( $connectedStr ) {
	$newNetworkDevice->{'connectable'} =
	    VirtualDeviceConnectInfo->new( allowGuestControl => $vnic_device->{'connectable'}->{'allowGuestControl'},
					   connected => $connected,
					   startConnected => $connected );
    }

    my $config_spec_operation = VirtualDeviceConfigSpecOperation->new('edit');
    my $vm_dev_spec = VirtualDeviceConfigSpec->new(device => $newNetworkDevice, operation => $config_spec_operation);
    my $vmChangespec = VirtualMachineConfigSpec->new(deviceChange => [ $vm_dev_spec ] );
    
    eval{
	my $task_ref = $vm_view->ReconfigVM_Task(spec => $vmChangespec);
	&getStatus($task_ref);
    };
    if($@) {
	print "Error: " . $@ . "\n";
	exit 1;
    }

    Util::disconnect();
}

main();
