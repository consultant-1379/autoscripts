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

sub main() {
    my %opts = 
	(
	 'vmname' => 
	 {
	     type => "=s",
	     help => "The name of the VM update",
	     required => 1,
	 },
	 'cpu' =>
	 {
	     type => "=s",
	     help => "The number of CPUs",
	     required => 0,
	 },
	 'mem' =>
	 {
	     type => "=s",
	     help => "The memory in MB",
	     required => 0,
	 },
	);

    # validate options, and connect to the server
    Opts::add_options(%opts);

    # validate options, and connect to the server
    Opts::parse();
    Opts::validate();
    Util::connect();

    my $vmName = Opts::get_option ('vmname');
    my $cpuCount = Opts::get_option ('cpu');
    my $memMB = Opts::get_option ('mem');

    my $vm = Vim::find_entity_view(view_type => 'VirtualMachine', 
				   filter => { 'name' => $vmName } );
    if ( ! $vm ) {
	print "Unable to locate $vmName!\n";
	exit 1;
    }

    my $vmChangespec = VirtualMachineConfigSpec->new();
    if ( $cpuCount ) {
	$vmChangespec->{numCPUs} = $cpuCount;
    }
    if ( $memMB ) { 
	$vmChangespec->{memoryMB} = $memMB;
    }

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
