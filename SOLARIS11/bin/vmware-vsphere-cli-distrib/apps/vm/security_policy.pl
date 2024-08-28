#!/usr/bin/perl -w
# This script is used to check or set the security policy settings of a vms distributed virtual port groups
# It specifically checks / sets the allowPromiscuous and macChanges values to Allow rather than Reject
use strict;
use warnings;
use Term::ANSIColor;
use VMware::VIRuntime;

# This function is used to get the status of a vcli task
# It will wait for the task to complete before returning
sub getStatus($) {
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

# This is the main function that will set / check the security policy status
sub main() {
	my %opts =  
		(
		 'vmname' => 
		 {
		 type => "=s",
		 help => "The name of the VM to update",
		 required => 1,
		 },
		 ,
		 'op' =>
		 {
		 type => "=s",
		 help => "The operation (set|check)",
		 required => 1,
		 }
		);

	Opts::add_options(%opts);
	Opts::parse();
	Opts::validate();

	my $vmName = Opts::get_option ('vmname');
	my $op = Opts::get_option ('op');

	if ($op ne "check" && $op ne "set")
	{
		print "ERROR: The op argument should be set to either set or check\n";
		exit 1;
	}

	Util::connect();

	my $vm_view = Vim::find_entity_view(view_type => 'VirtualMachine', filter => { 'name' => qr/\Q$vmName/ }, properties => ['network']);
	if ( ! $vm_view ) {
		print "Unable to locate $vmName!\n";
		Util::disconnect();
		exit 1;
	}
	if ( ! $vm_view->network) {
		print "Cound not find any networks connected to this vm\n";
		Util::disconnect();
		exit 1;
	}

	my $security_policy_status="Correct";

	foreach my $network_ref ( @{$vm_view->network} ) {
		if($network_ref->type eq 'DistributedVirtualPortgroup') {
			my $portgroup_view = Vim::get_view(mo_ref => $network_ref, properties => ['config']);
			if ($portgroup_view->config->defaultPortConfig->securityPolicy->allowPromiscuous->value != 1 || $portgroup_view->config->defaultPortConfig->securityPolicy->macChanges->value != 1 || $portgroup_view->config->defaultPortConfig->securityPolicy->forgedTransmits->value != 1)
			{
				if ($op eq "set")
				{
					$security_policy_status="Correct (needed modification)";
					my $spec = DVPortgroupConfigSpec->new(
							configVersion => $portgroup_view->config->configVersion,
							defaultPortConfig => VMwareDVSPortSetting->new(
								securityPolicy => DVSSecurityPolicy->new(
									allowPromiscuous => BoolPolicy->new('value' => 'true' , 'inherited' => 'false'),
									macChanges=> BoolPolicy->new('value' => 'true' , 'inherited' => 'false'),
									forgedTransmits => BoolPolicy->new('value' => 'true' , 'inherited' => 'false'),
									'inherited' => '0'
									)
								),
							);
					eval{
						my $r_task = $portgroup_view->ReconfigureDVPortgroup_Task(spec => $spec);
						getStatus($r_task);
					};
					if($@) {
						print "ERROR: " . $@ . "\n";
						Util::disconnect();
						exit 1;
					}
				}
				elsif ($op eq "check")
				{
					$security_policy_status="Incorrect";
					last;
				}
			}
		}
	}
	print "Security Policy Status: $security_policy_status\n";
	Util::disconnect();
}

# Start the main function
main();
