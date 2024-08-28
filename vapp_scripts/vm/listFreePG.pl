#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VIRuntime;
use VMware::VILib;

use Data::Dumper;

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

sub main() {
    my %opts = 
	(
	 'cluster' => {
	     type => "=s",
	     help => "The destination datastore",
	     required => 1,
	 },
	 'info' => {
	     type => "=s",
	     help => "Print verbose output",
	     required => 0,
	 }
	);

    # validate options, and connect to the server
    Opts::add_options(%opts);

    my $verboseStr = Opts::get_option("info");
    my $verbose = 1;
    if (  $verboseStr && $verboseStr eq "verbose" ) {
	$verbose = 1;
    }

    Opts::parse();
    Opts::validate();

    Util::connect();

    my $clusterName = Opts::get_option("cluster");
    my $cluster_view = Vim::find_entity_view(view_type => 'ClusterComputeResource', 
					     filter =>{ 'name' => $clusterName});
    my %hostRefs = ();
    foreach my $host_ref ( @{$cluster_view->{host}} ) {
	$hostRefs{$host_ref->{'value'}} = 1;
    }

    if ( ! $cluster_view ) {
	print "Unable to locate $clusterName!\n";
	Util::disconnect();
	exit 1;
    }
    foreach my $network_ref ( @{$cluster_view->{'network'}} ) {       
	my $network_view = Vim::get_view(mo_ref => $network_ref);
	if ( ! $network_view->{vm} ) { 
	    print $network_view->{name}, "\n";
	} else {
	    my $netUsed = 0;
	    foreach my $vm_ref ( @{$network_view->{vm}} ) {
		my $vm_view = Vim::get_view(mo_ref => $vm_ref);
		my $vm_host_ref = $vm_view->{runtime}->{host};
		if ( exists $hostRefs{$vm_host_ref->{value}} ) {
		    $netUsed++;
		}
	    }

	    if ( $netUsed == 0 ) {
		print $network_view->{name}, "\n";
	    }	   
	}
    }

    Util::disconnect();
}    

$| = 1;
main();
