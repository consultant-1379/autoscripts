#!/usr/bin/perl -w

use strict;
use warnings;
use Term::ANSIColor;
use VMware::VILib;
use VMware::VIRuntime;
use VMware::VIExt;
$SIG{__DIE__} = sub{Util::disconnect();};

my %opts = (
    vmname => {
        type => "=s",
        help => "Name of VM",
        required => 1,
    },
    datacenter => {
        type => "=s",
        help => "vSphere Datacenter",
        required => 1,
    },
    source_datastore => {
        type => "=s",
        help => "Source Datastore",
        required => 1,
    },
    destination_pool => {
        type => "=s",
        help => "Destination Pool",
        required => 1
    }
);

Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
register_vm();
Util::disconnect();
exit 1;

sub register_vm{
    my $datacenter = Opts::get_option('datacenter');
    my $vmname = Opts::get_option('vmname');
    my $source_datastore = Opts::get_option('source_datastore');
    my $destination_pool = Opts::get_option('destination_pool');
    my $datacenter_reference = Vim::find_entity_view(view_type => 'Datacenter', filter => {name => $datacenter});
    if(!$datacenter_reference) {
        Util::trace(0, "Error: Couldn't find a datacenter with this name $datacenter\n");
        exit 1
    }

    my $source_path = "[$source_datastore] $vmname";

    my $begin = Vim::find_entity_view (view_type => 'Datacenter', filter => {name => $datacenter});
    my $folder_view = Vim::get_view(mo_ref => $begin->vmFolder);
    my $vmxpath = $source_path . "/$vmname.vmx";

    my $pool_view = Vim::find_entity_view (view_type => 'ResourcePool', filter => {name => $destination_pool});
    my $vm_object = $folder_view->RegisterVM(
        path => $vmxpath,
        name => $vmname,
        asTemplate => 'false',
        pool => $pool_view
    );
    print "The vm reference is:" . $vm_object->value;
    Util::disconnect();
    exit 0;
}
