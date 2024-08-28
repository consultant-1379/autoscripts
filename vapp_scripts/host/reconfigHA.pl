#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VILib;
use VMware::VIRuntime;

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
    $Data::Dumper::Sortkeys = \&myFilter;

    my %opts = 
	(
	 'host' => {
	     type => "=s",
	     help => "The host",
	     required => 1,
	 },
	);
    Opts::add_options(%opts);
    Opts::parse();
    Opts::validate();

    Util::connect();

    my $hostName = Opts::get_option("host");
    my $host_view 
	= Vim::find_entity_view(view_type => 'HostSystem', 
				filter =>{ 'name' => $hostName});
    if ( ! $host_view ) {
	print "Unable to locate $hostName!\n";
	Util::disconnect();
	exit 1;
    }

    eval{
	my $task = $host_view->ReconfigureHostForDAS_Task();
	&getStatus($task);
    };
    if($@) {
	print "Error: " . $@ . "\n";
	exit 1;
    }
}

main();
