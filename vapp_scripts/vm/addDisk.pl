#!/usr/bin/perl -w

use strict;
use warnings;
use Term::ANSIColor;
use VMware::VIRuntime;
use VMware::VILib;

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
	sleep 5;
	$task_view->ViewBase::update_view_data();
    }
}

sub findSCSICtrlr($$) {
    my ($vm,$bus) = @_;

    my $devices = $vm->config->hardware->device;

    my $ctrlr = undef;
    foreach my $device ( @{$devices} ) {
	if ( $device->isa('VirtualLsiLogicSASController') ) {
	    if ( $device->busNumber eq $bus ) { 
		return $device;
	    }
	}
    }

    return undef;
}
    
sub addSCSICtrlr($$) {
    my ($vm,$bus) = @_;

    if($vm->runtime->powerState->val ne 'poweredOff') {
	Util::disconnect();
	print "ERROR: VM is still powered on or in suspend mode\n";
	exit 2;
    }

    my $newCtrlr = VirtualLsiLogicSASController->new( 'busNumber' => $bus, 
						      key => 0, 
						      device => [0],
						      sharedBus => VirtualSCSISharing->new('noSharing'));
    
						      
	
    
    my $changeOp = VirtualDeviceConfigSpecOperation->new('add');
    my $vmDevSpec = VirtualDeviceConfigSpec->new(device => $newCtrlr, 
						 operation => $changeOp);
    my $vmChangespec = VirtualMachineConfigSpec->new(deviceChange => [ $vmDevSpec ] );
    my $task_ref;
    eval{
	$task_ref = $vm->ReconfigVM_Task(spec => $vmChangespec);
	&getStatus($task_ref);
    };
    if($@) {
	print "ERROR: " . $@ . "\n";
	exit 3;
    }
}

sub main() {
    my %opts = 
	(
	 'vmname' => 
	 {
	     type => "=s",
	     help => "The name of the VM update",
	     required => 1,
	 },
	 'size' =>
	 {
	     type => "=s",
	     help => "The size of the disk in GB",
	     required => 1,
	 },
	 'bus' =>
	 {
	     type => "=s",
	     help => "The SCSI bus ID",
	     required => 1,
	 },
	 'unit' =>
	 {
	     type => "=s",
	     help => "The unit number of the disk",
	     required => 1,
	 },
	 'type' => {
	     type => "=s",
	     help => "The type disk (thin)",
	     required => 0,
	 }
	);
    
    # validate options, and connect to the server
    Opts::add_options(%opts);

    # validate options, and connect to the server
    Opts::parse();
    Opts::validate();
    Util::connect();

    my $vmName = Opts::get_option ('vmname');
    my $size = Opts::get_option ('size');
    my $bus = Opts::get_option ('bus');
    my $unit = Opts::get_option ('unit');

    my $vm = Vim::find_entity_view(view_type => 'VirtualMachine', 
				   filter => { 'name' => $vmName } );
    if ( ! $vm ) {
	print "Unable to locate $vmName!\n";
	exit 1;
    }

    my $ctrlr = findSCSICtrlr($vm,$bus);
    if ( ! $ctrlr ) {
	addSCSICtrlr($vm,$bus);
	$vm = Vim::get_view(mo_ref => $vm->{mo_ref});
	$ctrlr = findSCSICtrlr($vm,$bus);
    }

    my $datastore = Vim::get_view(mo_ref => $vm->datastore->[0] );

    my $type = Opts::get_option("type");
    my $thinProvisioned = 0;
    if ( (defined $type) && ($type eq "thin") ) {
	$thinProvisioned = 1;
    }

    my $dbi = VirtualDiskFlatVer2BackingInfo->new(
	thinProvisioned => $thinProvisioned,
	diskMode => 'persistent',
	fileName => '[' . $datastore->summary->name . ']');
   my $disk = VirtualDisk->new(
       backing => $dbi,
       controllerKey => $ctrlr->{key},
       key => 0,
       unitNumber => $unit,
       capacityInKB => $size * 1024 * 1024
       );
    my $dcs = VirtualDeviceConfigSpec->new(
	device => $disk,
	fileOperation => VirtualDeviceConfigSpecFileOperation->new('create'),
	operation => VirtualDeviceConfigSpecOperation->new('add')
	);

    my $vmChangespec = VirtualMachineConfigSpec->new(deviceChange => [ $dcs ] );
    my $r_task;
    eval{
	$r_task = $vm->ReconfigVM_Task(spec => $vmChangespec);
	&getStatus($r_task);
    };
    if($@) {
	print "ERROR: " . $@ . "\n";
	exit 3;
    }

    Util::disconnect();
}

main();

