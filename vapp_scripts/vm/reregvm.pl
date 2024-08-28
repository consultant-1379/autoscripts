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
	);

    # validate options, and connect to the server
    Opts::add_options(%opts);

    # validate options, and connect to the server
    Opts::parse();
    Opts::validate();
    Util::connect();

    my $vmName = Opts::get_option ('vmname');
    my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine', 
				   filter => { 'name' => $vmName } );
    if ( ! $vm_view ) {
	print "Unable to locate $vmName!\n";
	exit 1;
    }

    my $vmFolder_view;
    if ( $vm_view->{'parent'} ) {
	$vmFolder_view = Vim::get_view(mo_ref => $vm_view->{'parent'});
    } else {
	print "ERROR: Can't find folder\n";
	exit 1;
    }

    my $vmPath = $vm_view->{'config'}->{'files'}->{'vmPathName'};
    my $asTemplate = $vm_view->{'config'}->{'template'};
    my $pool = $vm_view->{'resourcePool'};
    if ( ! $pool ) {
	print "ERROR: Cannot find resourcePool\n";
	exit 1;
    }

    print "Unregister...";
    $vm_view->UnregisterVM();
    print "Done\n";

    print "Register...";
    eval {
	my $task_ref = $vmFolder_view->RegisterVM_Task(name => $vmName, path => $vmPath, asTemplate => $asTemplate, pool => $pool);
	&getStatus($task_ref);
    };
    if($@) {
	print "Error: " . $@ . "\n";
	exit 1;
    } 
    print "Done\n";
    
    Util::disconnect();
}
	
main();
