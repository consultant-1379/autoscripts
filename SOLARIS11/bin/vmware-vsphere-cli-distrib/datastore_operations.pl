#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VIRuntime;
use VMware::VILib;

my ($datastore_view, $operation, $datastore);

my %opts = (
    'operation' => {
        type => "=s",
        help => "Operation [unmount|mount]",
        required => 1,
    },
    'datastore' => {
        type => "=s",
        help => "Name of Datastore to perform the operation on",
        required => 1,
    }
);
Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
perform_operation();
Util::disconnect();
exit 1;

sub perform_operation {
    $operation = Opts::get_option('operation');
    $datastore = Opts::get_option('datastore');
    if ($operation ne "unmount" && $operation ne "mount")
    {
        print "ERROR: You must give a valid operation to perform\n";
        return 1;
    }
    $datastore_view = Vim::find_entity_view(view_type => 'Datastore', filter => {'name' => $datastore});
    unless (defined $datastore_view){
        print "Warning: Couldn't find a datastore called '$datastore'\n";
        Util::disconnect();
        exit 0;
    }

    if ($datastore_view->host) {
        my $attached_hosts = $datastore_view->host;
        foreach my $host (@$attached_hosts) {
            my $host_view = Vim::get_view(mo_ref => $host->key, properties => ['configManager.storageSystem','name','runtime.connectionState','runtime.inMaintenanceMode']);
            my $host_view_datastore_state = "";
            if (defined($host->mountInfo->mounted))
            {
                if ($host->mountInfo->mounted)
                {
                    $host_view_datastore_state = "mounted";
                } else {
                    $host_view_datastore_state = "unmounted";
                }
            } else {
                $host_view_datastore_state = "unsure";
            }
            if ($host_view_datastore_state eq "mounted" && $operation eq "mount")
            {
                next;
            }
            if ($host_view_datastore_state eq "unmounted" && $operation eq "unmount")
            {
                next;
            }
            if ($host_view->{'runtime.connectionState'}->val eq 'connected' && $host_view->{'runtime.inMaintenanceMode'} eq 'false') {
                my $storage_sys_view = Vim::get_view(mo_ref => $host_view->{'configManager.storageSystem'});
                eval {
                    if ($operation eq "unmount") {
                        $storage_sys_view->UnmountVmfsVolume(vmfsUuid => $datastore_view->info->vmfs->uuid);
                    } elsif ($operation eq "mount") {
                        $storage_sys_view->MountVmfsVolume(vmfsUuid => $datastore_view->info->vmfs->uuid);
                    }
                };
                if ($@) {
                    print "ERROR: Unable to $operation VMFS datastore $datastore on host $host_view->{'name'}" . $@ . "\n";
                    return 1;
                }
            }
        }
    }
    Util::disconnect();
    exit 0;
}
