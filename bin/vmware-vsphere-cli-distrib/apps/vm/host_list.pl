#!/usr/bin/perl -w

# List all VM's in a specific VMware Infrastructure Cluster
# Written by: Jeremy van Doorn (jvandoorn@vmware.com)
#
# This program lists all VM's in a specific Cluster.
# It will report the name of Host and the VM in a formatted table.
# At the bottom of the table, it shows the amount of VM's and Hosts found in the Cluster.
#
# This program uses the VI Perl Tool kit, which you can download from:
# http://www.sourceforge.net/projects/viperltoolkit
#
# Version History:
# V1.0.0 - 20070417 Written by request
# v1.0.1 - 20070418 Added error-trapping for incorrect Cluster Names

########## Setting the default variables for being able to work with the VMware Webservice

use strict;
use warnings;
use Term::ANSIColor;
#use VMware::VILib;
use VMware::VIRuntime;

$SIG{__DIE__} = sub{Util::disconnect();};
my %opts = (
                cluster => {
                type => "=s",
                help => "Cluster name",
                required => 1,
                }
           );
Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
########## Set your username and password and define where the VMware Web Service can be located

my $cluster_name = Opts::get_option('cluster');

########## Login to the VMware Infrastrucure Web Service
#Vim::login(service_url => $service_url, user_name => $username, password => $password);
########## Get a view of the specified Cluster
my $cluster_view = Vim::find_entity_view(view_type => 'ClusterComputeResource', filter => { name => $cluster_name });
########## Error trap: verify if the cluster_view variable was set in the previous command
##########             if it was not set, the Cluster Name is incorrect
if (!$cluster_view) {
   die  "\nERROR: '" . $cluster_name . "' was not found in the VMware Infrastructure\n\n";
}
########## Print the table header

########## Get a view of the ESX Hosts in the specified Cluster
my $host_views = Vim::find_entity_views(view_type => 'HostSystem',
                                        begin_entity => $cluster_view,
					properties => ['name']);
                                        

foreach my $host (@$host_views) {
	print $host->name . "\n"
}


########## Logout of the VMware Infrastructure Web Service
#Vim::logout();
Util::disconnect();
