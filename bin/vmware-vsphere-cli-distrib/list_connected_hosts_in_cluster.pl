#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VILib;
use VMware::VIRuntime;

my ($cluster_view, $cluster_name, $hosts);

my %opts = (
    cluster => {
        type => "=s",
        help => "The name of a vCenter cluster to list the hosts in",
        required => 1
    }
);

Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
list();
Util::disconnect();
exit 1;

sub list{
    $cluster_name = Opts::get_option('cluster');
    $cluster_view = Vim::find_entity_view(view_type => 'ClusterComputeResource', filter => { name => $cluster_name }, properties => ['host']);
    unless (defined $cluster_view){
        print "ERROR: Couldn't find a cluster called '$cluster_name'\n";
        return 1;
    }
    $hosts = Vim::get_views (mo_ref_array => $cluster_view->host, properties => ['name','runtime.connectionState','runtime.inMaintenanceMode']);
    foreach my $host (@$hosts) {
        if ($host->{'runtime.connectionState'}->val eq 'connected' && $host->{'runtime.inMaintenanceMode'} eq 'false') {
            print "HOST: " . $host->name . "\n";
        }
    }
    Util::disconnect();
    exit 0;
}
