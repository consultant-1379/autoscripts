#!/usr/bin/perl -w
# William Lam 
# 01/13/2010
# http://engineering.ucsb.edu/~duonglt/vmware

use strict;
use warnings;
use VMware::VILib;
use VMware::VIRuntime;
use Term::ANSIColor;

sub myFilter {
    my ($hash) = @_;
    my @keys = sort keys %{$hash};
    my @result = ();
    foreach my $key ( @keys ) {
	if ( $key ne "vim" ) {
	    push @result, $key;
	}
    }
    return \@result;
}

sub findDVS($$$) {
    my ($sc, $dvsMgr, $dvsName) = @_;
    my $host_views = Vim::find_entity_views(view_type => 'HostSystem');

    foreach my $host (@$host_views) {
	my $dvsTargets = $dvsMgr->QueryDvsConfigTarget(host => $host);
	if ( $dvsTargets->distributedVirtualSwitch ) {
	    foreach my $dvsTarget (@{$dvsTargets->distributedVirtualSwitch}) {
		if ( $dvsTarget->switchName eq $dvsName ) { 
		    return Vim::get_view(mo_ref => $dvsTarget->distributedVirtualSwitch);
		}
	    }
	}
    }

    my %dvsRefs = ();
    my $datacenter_views = Vim::find_entity_views(view_type => 'Datacenter');
    foreach my $dc_view  ( @${datacenter_views} ) {
	my $network_refs = $dc_view->{network};
	foreach my $network_ref ( @${network_refs} ) {
	    if($network_ref->type eq 'DistributedVirtualPortgroup') {
		my $dvpg = Vim::get_view(mo_ref => $network_ref);		
		my $dvs_ref = $dvpg->config->distributedVirtualSwitch;
		if ( ! exists $dvsRefs{$dvs_ref->value} ) {
		    my $dvs = Vim::get_view( mo_ref => $dvs_ref );
		    if ( $dvs->name eq $dvsName ) {
			return $dvs;
		    } else { 
			$dvsRefs{$dvs_ref->value} = 1;
		    }
		}
	    }
	}
    }

    return undef;
}

sub getStatus {
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

sub addPortGroup($$$) {
    my ($dvs,$pgName,$vlanId) = @_;

    my $vlanSpec = VmwareDistributedVirtualSwitchVlanIdSpec->new(vlanId => $vlanId, inherited => 0);
    my $dvps = 	VMwareDVSPortSetting->new(vlan => $vlanSpec);
    my $dpgConfigSpec = DVPortgroupConfigSpec->new(name => $pgName, 
						   type => 'ephemeral',
	                                           defaultPortConfig => $dvps);
    
    eval{
	my $task = $dvs->AddDVPortgroup_Task(spec => [ $dpgConfigSpec ] );
	&getStatus($task);
    };
    if($@) {
	print "Error: " . $@ . "\n";
    }
}

sub addHost($$$) {
    my ($dvs_view,$host_view, $nic_name) = @_;


    my $r_pnicArray;
    my $operation = 'add';
    if ( $dvs_view->config->host ) { 
	foreach my $memberHost ( @{$dvs_view->config->host} ) {
	    my $host_ref = $memberHost->config->{host};
	    if ( $host_ref->{value} eq $host_view->{mo_ref}->value ) {
		$r_pnicArray = $memberHost->config->backing->pnicSpec;
	    }
	}
    }
    if ( $r_pnicArray ) {
	$operation = 'edit';
    } else {
	$r_pnicArray = [];
    }
    
    my $nicspec = DistributedVirtualSwitchHostMemberPnicSpec->new( pnicDevice => $nic_name );
    push @{$r_pnicArray}, $nicspec;
    my $backing = DistributedVirtualSwitchHostMemberPnicBacking->new( pnicSpec => $r_pnicArray );
    my $hostConfig = DistributedVirtualSwitchHostMemberConfigSpec->new( operation => $operation,
									host => $host_view->{mo_ref}, 
									backing => $backing );
    my $dvsCfgSpec = DVSConfigSpec->new( configVersion => $dvs_view->config->configVersion, 
					 host => [ $hostConfig ] );

    eval{
	my $task = $dvs_view->ReconfigureDvs_Task( spec => $dvsCfgSpec );
	&getStatus($task);
    };
    if($@) {
	print "Error: " . $@ . "\n";
	exit 1;
    }        
}

sub delPortGroup($$) {
    my ($dvs,$pgName) = @_;

    my $thepg_view;
    foreach my $pg_ref ( @{$dvs->portgroup} ) {
	my $pg_view = Vim::get_view(mo_ref => $pg_ref);
	if ( $pg_view->{name} eq $pgName ) { 
	    $thepg_view = $pg_view;
	}
    }

    if ( $thepg_view ) {
	eval{
	    my $task = $thepg_view->Destroy_Task();
	    &getStatus($task);
	};
	if($@) {
	    print "Error: " . $@ . "\n";
	    exit 1;
	}
    } else {
	print "ERROR: Could not find portgroup $pgName\n";
	exit 1;
    }    
}

sub rmHost($$) {
    my ($dvs_view,$host_view) = @_;

    my $hostConfig = 
	DistributedVirtualSwitchHostMemberConfigSpec->new( 
	    operation => 'remove',
	    host => $host_view->{mo_ref}, 
	);
    my $dvsCfgSpec = DVSConfigSpec->new( configVersion => $dvs_view->config->configVersion, 
					 host => [ $hostConfig ] );

    eval{
	my $task = $dvs_view->ReconfigureDvs_Task( spec => $dvsCfgSpec );
	&getStatus($task);
    };
    if($@) {
	print "Error: " . $@ . "\n";
	exit 1;
    }        
}
    
sub main() {
    $Data::Dumper::Sortkeys = \&myFilter;

    my %opts = 
	(
	 'dvs' => 
	 {
	     type => "=s",
	     help => "The name of the dvSwitch",
	     required => 1,
	 },
	 
	 'pg' => {
	     type => "=s",
	     help => "The name portgroup create",
	     required => 0,
	 },

	 'op' => {
	     type => "=s",
	     help => "The operation to perform",
	     required => 1,
	 },
	 
	 'vlan' => {
	     type => "=s",
	     help => "The VLAN ID",
	     required => 0,
	 },
	 'host' => {
	     type => "=s",
	     help => "The host",
	     required => 0,
	 },
	 'nic' => {
	     type => "=s",
	     help => "The nic",
	     required => 0,
	 }
	);
    Opts::add_options(%opts);
    Opts::parse();
    Opts::validate();

    my $dvsName = Opts::get_option ('dvs');
    my $pgName = Opts::get_option ('pg');
    my $op = Opts::get_option ('op');


    Util::connect();

    my $sc = Vim::get_service_content();
    my $dvsMgr = Vim::get_view(mo_ref => $sc->dvSwitchManager);
    my $dvs = findDVS($sc,$dvsMgr,$dvsName);
    if ( ! defined $dvs ) {
	print "ERROR: No dvSwitch found called $dvsName";
	Util::disconnect();
	exit 1;
    }

    my $hostName = Opts::get_option("host");
    my $host_view;
    if ( $hostName ) {
	$host_view 
	    = Vim::find_entity_view(view_type => 'HostSystem', 
				    filter =>{ 'name' => $hostName});
	if ( ! $host_view ) {
	    print "Unable to locate $hostName!\n";
	    Util::disconnect();
	    exit 1;
	}
    }

    if ( $op eq "delpg" ) {
	delPortGroup($dvs,$pgName);
    } elsif ( $op eq "addpg" ) {
	my $vlanId = Opts::get_option ('vlan');
	addPortGroup($dvs,$pgName,$vlanId);
    } elsif ( $op eq "addhost" ) {
	my $nic = Opts::get_option("nic");
	addHost($dvs,$host_view,$nic);
    } elsif ( $op eq "rmhost" ) {
	rmHost($dvs,$host_view);
    }



    Util::disconnect();
}

main();
