#!/usr/bin/perl -w
#
#
# This scripts allows users to move all running vm's from one host to another.
# Modified by Darren Patterson to be multithreaded and include an option to place the
# source ESX server into maintenance mode after the evac finishes.

use strict;
use warnings;
use threads;
use threads::shared;

use VMware::VIRuntime;
use VMware::VILib;

# MAX number of concurrently running evac processes.
my $MAXT = 6;

# seconds to sleep while checking for completed threads.
my $SLEEPSIZE = 8;

my %opts = (
   dst => {
      type => "=s",
      help => "Destination host for VMs",
      required => 1,
   },
   vmname => {
	type => "=s",
	help => "VM name",
	required => 1,
   },
);

# read/validate options and connect to the server
Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();

# get source host view
#my $src_host_name = Opts::get_option('src');
#my $src_host_view = Vim::find_entity_view(view_type => 'HostSystem',
#                                          filter => { name => $src_host_name });

#if (!$src_host_view) {
#   die "Source host '$src_host_name' not found\n";
#}

my $vmName = Opts::get_option ('vmname');

# get destination host view
my $dst_host_name = Opts::get_option('dst');

# the destination host view must be a shared variable for threads to see
my $dst_host_view = Vim::find_entity_view(view_type => 'HostSystem',
                                          filter => { name => $dst_host_name });


if (! $dst_host_view) {
   die "Destination host '$dst_host_name' not found\n";
}

# get all VM's under src host
#my $vm_views = Vim::find_entity_views(view_type => 'VirtualMachine', filter => { 'runtime.powerState' => 'poweredOff',  'name' => $vmName }, begin_entity => $src_host_view);
my $vm_views = Vim::find_entity_views(view_type => 'VirtualMachine', filter => { 'runtime.powerState' => 'poweredOff',  'name' => $vmName });

# migrate all vm's
#print "Starting threads...\n";
#my @results : shared;
#my $inc = 0;
foreach (@$vm_views) {
	evac ($dst_host_view,$_,'poweredOff');
}

$vm_views = Vim::find_entity_views(view_type => 'VirtualMachine', filter => { 'runtime.powerState' => 'suspended',  'name' => $vmName });

# migrate all vm's
#print "Starting threads...\n";
#my @results : shared;
#my $inc = 0;
foreach (@$vm_views) {
        evac ($dst_host_view,$_,'suspended');
}

#print "Waiting for all VMotion threads to finish...\n";
#sleep ($SLEEPSIZE) while ($#results+1 < @$vm_views);

my $return;
#foreach (@results) {
#    if (/returned 2$/) {
#        $return = 2;
#        print STDERR "An error was returned by a VMotion thread.\n";
#    }
#}
# Note: Specifically don't join threads to avoid double free segfault.
# Let perl do the cleanup on exit.
#
# Loop through all the threads 
#   foreach my $thr (threads->list) { 
   # Don't join the main thread or ourselves 
#   if ($thr->tid && !threads::equal($thr, threads->self)) { 
#      $thr->join if (defined($thr) && print "joined thread: ".$thr->tid."\n"); 
#   } 
#}

# it may still be possible to enter maintenance mode even though an error
# may have happened earlier
#if (Opts::get_option('maint')) {
#   print "Putting ".$src_host_name." into maintenance mode...\n";
#   $return = enter_maintenance($src_host_view);
#}


# disconnect from the server
Util::disconnect();                                  
#return $return;

sub evac {
   my $dst_host_view = shift;
   my $vm = shift;
   my $powerstate = shift;

   eval {
      print "Starting VMotion for ".$vm->name." in state ". $powerstate ."\n";
      $vm->MigrateVM(host => $dst_host_view,
                    priority => VirtualMachineMovePriority->new('defaultPriority'),
                    state => VirtualMachinePowerState->new($powerstate));
      print "VM " . $vm->name . " vMotioned successfully.\n";
      #push (@results, (threads->self)->tid." returned 0");
      return 0;
   };
   if ($@ && $vm->runtime->powerState->val eq 'poweredOn') {
      # unexpected error
      print "Unable to vMotion VM '" . $vm->name . "'\n";
      print "Reason: " . $@ . "\n\n";
      #push (@results, (threads->self)->tid." returned 2");
      return 2;
   }
}



##############################################################################
# Documentation
##############################################################################

=head1 NAME

vmevac - evacuate an ESX server's VM guests to another ESX server

=head1 SYNOPSIS

B<vmevac> B<--src> I<ESX-to-evacuate> B<--dst> I<dest-for-vms> [B<--maint>]

=head1 DESCRIPTION

Evacuate an ESX server's VM guests to another ESX server.

=head1 OPTIONS

=over 4

=item B<-h>, B<--help>

Print out help.

=item B<--dst> I<ESX-server>

The destination ESX server to relocate VM guests to.

=item B<--maint> 

Place the source ESX server into maintenance mode after evacuation.

=item B<--src> I<ESX-server>

The souce ESX server to evacuate VM guests from.

=back

=head1 EXAMPLES

vmevac --src hal07.stanford.edu --dst hal08.stanford.edu
vmevac --src hal07.stanford.edu --dst hal08.stanford.edu --maint
