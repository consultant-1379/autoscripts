#!/usr/bin/perl -w
#
use strict;
use warnings;
use Term::ANSIColor;
use VMware::VIRuntime;
#use VMware::VILib;

sub getStatus($) {
    my ($taskRef) = @_;
    
    my $task_view = Vim::get_view(mo_ref => $taskRef);
    my $taskinfo = $task_view->info->state->val;
    my $continue = 1;
    while ($continue) {
	print "Waiting\n";
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
	     help => "The name of the VM update",
	     required => 1,
	 },
	 'op' =>
	 {
	     type => "=s",
	     help => "The operation (add|remove)",
	     required => 1,
	 },

	 'host' =>
	 {
	     type => "=s",
	     help => "The ESXi hostname",
	     required => 0,
	 },
	 'port' =>
	 {
	     type => "=s",
	     help => "The port number",
	     required => 0,
	 },	 
	 'vspc' =>
	 {
	     type => "=s",
	     help => "The vSPC host",
	     required => 0,
	 },	 	 
	);

    # validate options, and connect to the server
    Opts::add_options(%opts);

    # validate options, and connect to the server
    Opts::parse();
    Opts::validate();

    my $vmName = Opts::get_option ('vmname');
    my $op = Opts::get_option ('op');

    my $hostname = Opts::get_option ('host');
    my $portNum;
    my $vspc;
    if ( $hostname ) {
	$portNum = Opts::get_option ('port');
	if ( ! $portNum ) {
	    print "ERROR: No port specified\n";
	    exit 1;
	}
    } else {
	$vspc = Opts::get_option ('vspc');
	if ( $op ne "check" )
	{
		if ( ! $vspc && $op ne "remove" ) {
		    print "ERROR: You must specify either host and port or vspc\n";
		    exit 1;
		}
	}
    }
      


    Util::connect();

    my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine', 
				   filter => { 'name' => $vmName },properties => ['config']);
    if ( ! $vm_view ) {
	print "Unable to locate $vmName!\n";
	exit 1;
    }


    my $vsp;
    foreach my $device ( @{$vm_view->config->hardware->device} ) {
	if ( $device->isa('VirtualSerialPort') ) {
	    $vsp = $device;
	}
    }
    if ( $op eq "check" ) {
	if ( $vsp ) {
		print "This VM already has a serial port\n";
		print "$vsp->{'backing'}->{'proxyURI'}\n";
	}
	else
	{
		print "This VM already has not got serial port\n";
	}
	exit 0;
    } elsif ( $op eq "add" ) {
	if ( $vsp ) { 
	    print "WARN: This VM already has a serial port! Updating configuration\n";
	    print "$vsp->{'backing'}->{'proxyURI'}\n";
	exit 0;
	    $op = "edit";
	}

	my $vsp_back;
	if ( $hostname ) {
	    $vsp_back = VirtualSerialPortURIBackingInfo->new( 
		serviceURI => "telnet://" . $hostname . ":" . $portNum,
		direction => "server" );
	} else {
	    $vsp_back = VirtualSerialPortURIBackingInfo->new( 
		proxyURI => "telnet://" . $vspc . ":" . 13370,
		serviceURI => "vSPC.py",
		direction => "server" );
	}
	$vsp = VirtualSerialPort->new( backing => $vsp_back,
				       yieldOnPoll => 1,
				       key => 0,
				       unitNumber => 0 );
    } elsif ( $op eq "remove" ) {
	if ( ! $vsp ) {
	    print "ERROR: Count not find serial port to remove\n";
	    Util::disconnect();
	    exit 1;
	}
    } else { 
	print "ERROR: Unknown op \"$op\"\n";
	Util::disconnect();
	exit 1;
    }

    my $operation = VirtualDeviceConfigSpecOperation->new($op);
    my $dcs = VirtualDeviceConfigSpec->new(	
	device => $vsp,
	operation => $operation
	);
    my $vmChangespec = VirtualMachineConfigSpec->new(deviceChange => [ $dcs ] );

    my $r_task;
    eval{
	$r_task = $vm_view->ReconfigVM_Task(spec => $vmChangespec);
	getStatus($r_task);
    };
    if($@) {
	print "ERROR: " . $@ . "\n";
	exit 3;
    }

    Util::disconnect();
}
	
main();
