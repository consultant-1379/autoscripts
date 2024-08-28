#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VILib;
use VMware::VIRuntime;

my ($host_name, $host_view);

my %opts = (
    host => {
        type => "=s",
        help => "The name of a host to rescan all hbas on",
        required => 1
    }
);

Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
rescan();
Util::disconnect();
exit 1;

sub rescan {
    $host_name = Opts::get_option('host');
    $host_view = Vim::find_entity_view(view_type => 'HostSystem', filter => { name => $host_name }, properties => ['configManager.storageSystem']);
    unless (defined $host_view){
        print "ERROR: Couldn't find a host called '$host_name'\n";
        return 1;
    }
    my $storage_system = Vim::get_view(mo_ref => $host_view->{'configManager.storageSystem'});
    eval {
        $storage_system->RescanAllHba();
    };
    if($@) {
        print "ERROR: Rescan all HBAs failed for host ", $host_name, ".\n";
        print $@;
        return 1;
    }
    eval {
        $storage_system->RescanVmfs();
    };
    if($@) {
        print "ERROR: Rescan for new VMFS volumes failed for host ", $host_name, ".\n";
        print $@;
        return 1;
    }
    eval {
        $storage_system->RefreshStorageSystem();
    };
    if($@) {
        print "ERROR: Refresh storage information failed for host ", $host_name, ".\n";
        print $@;
        return 1;
    }
    Util::disconnect();
    exit 0;
}
