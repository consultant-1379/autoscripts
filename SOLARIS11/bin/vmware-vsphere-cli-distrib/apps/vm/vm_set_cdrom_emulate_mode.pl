#!/usr/bin/perl -w
# William Lam
# 02/03/2009
# http://engineering.ucsb.edu/~duonglt/vmware/
##################################################

use strict;
use warnings;
use Term::ANSIColor;
use VMware::VILib;
use VMware::VIRuntime;

$SIG{__DIE__} = sub{Util::disconnect();};

my %opts = (
		vmname => {
		type => "=s",
		help => "Name of VM",
		required => 1,
		},
		cdromkey=> {
		type => "=s",
		help => "Device key",
		required => 1,
		},
	   );

Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
update_drive();
Util::disconnect();
exit 1;

sub getStatus($) {
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

sub update_drive{
	my $vmname = Opts::get_option('vmname');
	my $cdromkey = Opts::get_option('cdromkey');

	my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine',filter => {'name' =>  qr/$vmname/}, properties => ['config']);
	if(!$vm_view) {
		Util::trace(0, "Error: Couldn't find a vm with this name $vmname\n");
		exit 1
	}
	my $devices = $vm_view->config->hardware->device;

	my ($key,$unitNumber,$backing,$controllerKey,$is_emulate);

	#figure out the device you want to edit and 
	#grab all attributes 
	foreach my $device (@$devices){
		# Make sure its a cdrom and that the key matches what the user input
		if($device->isa("VirtualCdrom") && ($device->key==$cdromkey)) {
			$key = $device->key;
			$controllerKey = $device->controllerKey;
			$unitNumber = $device->unitNumber;
			$backing = $device->backing;
			$is_emulate = $backing->isa('VirtualCdromRemoteAtapiBackingInfo');
			if (!$is_emulate)
			{
			my $specOp = VirtualDeviceConfigSpecOperation->new('edit');
			my $virtualdevice = VirtualCdrom->new(
					controllerKey => $controllerKey,
					key => $key,
					backing => VirtualCdromRemoteAtapiBackingInfo->new(deviceName => 'No Devices available'),
					unitNumber => $unitNumber
					);

			my $virtdevconfspec = VirtualDeviceConfigSpec->new(
					device => $virtualdevice,
					operation => $specOp
					);

			my $virtmachconfspec = VirtualMachineConfigSpec->new(
					deviceChange => [$virtdevconfspec],
					);
			my $r_task;
			eval {
				$r_task = $vm_view->ReconfigVM_Task( spec => $virtmachconfspec );
				getStatus($r_task);
			};

			if ($@) {
				Util::trace(0, "\nReconfiguration failed: ");
				if (ref($@) eq 'SoapFault') {
					if (ref($@->detail) eq 'TooManyDevices') {
						Util::trace(0, "\nNumber of virtual devices exceeds "
								. "the maximum for a given controller.\n");
					}
					elsif (ref($@->detail) eq 'InvalidDeviceSpec') {
						Util::trace(0, "The Device configuration is not valid\n");
						Util::trace(0, "\nFollowing is the detailed error: \n\n$@");
					}
					elsif (ref($@->detail) eq 'FileAlreadyExists') {
						Util::trace(0, "\nOperation failed because file already exists");
					}
					elsif(ref($@->detail) eq 'NotSupported') {
				                Util::trace(0,"Virtual machine is marked as template");
             				}
					else {
						Util::trace(0, "\n" . $@ . "\n");
					}
				}
			} else {
				#Util::trace(0, "\n" . $@ . "\n");
			}
			}
		}
	}
	Util::disconnect();
	exit 0;
}
