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
	 'svm' => 
	 {
	     type => "=s",
	     help => "The name of the source VM",
	     required => 1,
	 },
	 'snap' => 
	 {
	     type => "=s",
	     help => "The name of the snapshot in the source VM",
	     required => 1,
	 },
	 'cvm' => 
	 {
	     type => "=s",
	     help => "The name of the clone VM",
	     required => 1,
	 },

	);

    # validate options, and connect to the server
    Opts::add_options(%opts);

    # validate options, and connect to the server
    Opts::parse();
    Opts::validate();
    Util::connect();

    my $vmName = Opts::get_option ('svm');
    my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine', 
				   filter => { 'name' => $vmName } );
    if ( ! $vm_view ) {
	print "Unable to locate $vmName!\n";
	exit 1;
    }

    my $snapname = Opts::get_option ('snap');
    my $snap_ref;
    foreach my $snap ( @{$vm_view->{'snapshot'}->{'rootSnapshotList'}} ) {
	if ( $snap->{'name'} eq $snapname ) {
	    $snap_ref = $snap->{'snapshot'};
	}
    }
    if ( ! $snap_ref ) { 
	print "Unable to locate $snapname!\n";
	exit 1;
    }

    my $relocSpec = VirtualMachineRelocateSpec->new( diskMoveType => "createNewChildDiskBacking" );
    my $cloneSpec = VirtualMachineCloneSpec->new( powerOn => 0, 
						  template => 0, 
						  location => $relocSpec, 
						  snapshot => $snap_ref );


    my $cvmName = Opts::get_option ('cvm');
    
    my $parent_ref = $vm_view->{'parent'};
    if ( ! $parent_ref && $vm_view->{'parentVApp'}) {
	my $vapp_view = Vim::get_view(mo_ref => $vm_view->{'parentVApp'});
	$parent_ref = $vapp_view->{parentFolder};
    }

    my $task_ref;
    eval{
	$task_ref = 
	    $vm_view->CloneVM_Task(folder => $parent_ref,
				   name => $cvmName,
				   spec => $cloneSpec,
	    );
	&getStatus($task_ref);
    };
    if($@) {
	print "Error: " . $@ . "\n";
	Util::disconnect();
	exit 1;
    } 
}

main();
