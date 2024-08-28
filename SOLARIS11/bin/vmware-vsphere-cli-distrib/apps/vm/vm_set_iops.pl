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
		iops=> {
		type => "=s",
		help => "New iops",
		required => 1,
		},
	   );

Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
update_iops();
Util::disconnect();
exit 1;

sub update_iops {
	my $vmname = Opts::get_option('vmname');
	my $iops = Opts::get_option('iops');

	my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine',filter => {'name' =>  $vmname}, properties => ['config']);
	if(!$vm_view) {
		Util::trace(0, "Error: Couldn't find a vm with this name $vmname\n");
		exit 1
	}
	my $devices = $vm_view->config->hardware->device;

	my ($key,$unitNumber,$backing,$controllerKey,$type,$capacityInKB);

#figure out the device you want to edit and 
#grab all attributes 
	foreach my $device (@$devices){
		if($device->isa("VirtualDisk")) {
			$key = $device->key;
			$controllerKey = $device->controllerKey;
			$unitNumber = $device->unitNumber;
			$backing = $device->backing;
			$capacityInKB = $device->capacityInKB;
			#print $device->storageIOAllocation->limit;
			if ($device->storageIOAllocation->limit != $iops)
			{
			my $specOp = VirtualDeviceConfigSpecOperation->new('edit');
			my $virtualdevice = VirtualDisk->new(
					controllerKey => $controllerKey,
					key => $key,
					backing => $backing,
					unitNumber => $unitNumber,
					capacityInKB => $capacityInKB,
					storageIOAllocation => StorageIOAllocationInfo->new( limit => $iops)
					);

			my $virtdevconfspec = VirtualDeviceConfigSpec->new(
					device => $virtualdevice,
					operation => $specOp
					);

			my $virtmachconfspec = VirtualMachineConfigSpec->new(
					deviceChange => [$virtdevconfspec],
					);

			eval {
				$vm_view->ReconfigVM_Task( spec => $virtmachconfspec );
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
	# Finished all disks, exit 0
	Util::disconnect();
	exit 0;
}
