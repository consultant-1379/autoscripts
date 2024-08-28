#!/usr/bin/perl -w
#
use strict;
use warnings;
use VMware::VIRuntime;

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

    my $vmName = Opts::get_option ('vmname');

    Util::connect();

    my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine', 
				   filter => { 'name' => $vmName },properties => ['runtime.powerState']);
    if ( ! $vm_view ) {
	print "Unable to locate $vmName!\n";
	exit 1;
    }

    print $vm_view->{"runtime.powerState"}->val;

    Util::disconnect();
}
	
main();
