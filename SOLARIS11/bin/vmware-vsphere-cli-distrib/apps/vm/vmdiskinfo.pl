#!/usr/bin/perl -w
##################################################################
# Author: William Lam
# 10/11/2009
# http://engineering.ucsb.edu/~duonglt/vmware/
# Modified by: Martin Pugh
# 11/25/2009
# Modified to make a simplier output for backup script
##################################################################
use strict;
use warnings;
use Term::ANSIColor;
use VMware::VIRuntime;
use VMware::VILib;

my %opts = (
   vmname => {
      type => "=s",
      help => "The name of the virtual machine",
      required => 1,
	  default => "all"
   },
);

$SIG{__DIE__} = sub{Util::disconnect();};

Opts::add_options(%opts);

# validate options, and connect to the server
Opts::parse();
Opts::validate();
Util::connect();

my ($vm_view,$vmname,$vm_output_string);

$vmname = Opts::get_option('vmname');
$vm_output_string = "";
$vm_view = Vim::find_entity_views(view_type => 'VirtualMachine', filter => { 'name' => $vmname });

foreach( sort {$a->summary->config->name cmp $b->summary->config->name} @$vm_view) {
	if($_->summary->runtime->connectionState->val eq 'connected') {
	if(!$_->config->template) {
	if(($_->summary->config->name eq $vmname) || ($vmname eq "all")) {
		my $displayname = $_->summary->config->name;
		my $devices = $_->config->hardware->device;
		my $disk_string;
		foreach(@$devices) {
			if($_->isa('VirtualDisk')) {
				my $label = $_->deviceInfo->label;
				my $diskName = $_->backing->fileName;
				$disk_string .= "\t" . $label . " = " . $diskName . "\n";
			}
		}
		$vm_output_string .= $displayname . "\n" . $disk_string . "\n"
	}
	}
	}
}

if($vm_output_string eq "") {
	print "Error! VM not found: " . $vmname
} else {
	print $vm_output_string;
}

Util::disconnect();
