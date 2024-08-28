#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VIRuntime;
use VMware::VILib;

my %opts = (
        'vmname' => {
        type => "=s",
        help => "The name of the virtual machine",
        required => 1,
        },
        'operation' => {
        type => "=s",
        help => "Operation [query|update]",
        required => 1,
        },
	'bootdelay' => {
        type => "=s",
        help => "Boot delay in milliseconds before starting the boot sequence",
        required => 0,
        },
);
# validate options, and connect to the server
Opts::add_options(%opts);

# validate options, and connect to the server
Opts::parse();
Opts::validate();
Util::connect();

my $vmname = Opts::get_option ('vmname');
my $operation = Opts::get_option ('operation');
my $bootdelay = Opts::get_option ('bootdelay');

my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine', filter =>{ 'name'=> $vmname}, properties => ['name','config.bootOptions']);

if($vm_view) {
	if($operation eq "query") {
		if(defined($vm_view->{'config.bootOptions'})) {
			print "Boot delay for \"" . $vmname . "\" is " . $vm_view->{'config.bootOptions'}->bootDelay . " ms\n";
		} else {
			print "No bootOptions found for \"" . $vmname . "\"\n";
		}	
	} elsif($operation eq "update") {
		unless($bootdelay) {
			Util::disconnect();
			print "\nPlease specify the boot delay option using --bootdelay\n";
			exit 1;
		}

		my $bootOptions = VirtualMachineBootOptions->new(bootDelay => $bootdelay);
		my $spec = VirtualMachineConfigSpec->new(bootOptions => $bootOptions);
		my $msg = "Successfully updated VM Boot Delay";
		print "Reconfiguring VM Boot Delay to $bootdelay ms ...\n";
		my $task = $vm_view->ReconfigVM_Task(spec => $spec);
		&getStatus($task,$msg);
	} else {
		print "\nInvalid Operation\n";	
	}
} else {
        print "\nUnable to locate $vmname!\n";
        exit 0;
}

Util::disconnect();

sub getStatus {
        my ($taskRef,$message) = @_;

        my $task_view = Vim::get_view(mo_ref => $taskRef);
        my $taskinfo = $task_view->info->state->val;
        my $continue = 1;
        while ($continue) {
                my $info = $task_view->info;
                if ($info->state->val eq 'success') {
                        print $message,"\n";
                        return $info->result;
                        $continue = 0;
                } elsif ($info->state->val eq 'error') {
                        my $soap_fault = SoapFault->new;
                        $soap_fault->name($info->error->fault);
                        $soap_fault->detail($info->error->fault);
                        $soap_fault->fault_string($info->error->localizedMessage);
                        die "$soap_fault\n";
                }
                sleep 5;
                $task_view->ViewBase::update_view_data();
        }
}
