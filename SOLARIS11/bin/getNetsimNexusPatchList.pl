#!/usr/bin/perl

#####################################################################################
##
##     Filename : getNetsimNexusPatchList.pl
#
##     Version : 1.0
##
##     Author : Goutham Malla
##
##     Description : Generates config file based on product and drop
##
##     Date Created : 02 January 2017
##
##     Syntax : ./getNetsimNexusPatchList.pl -p Product -d Drop -v NetsimVersion
##
##     Parameters : <drop> The release version
##                  <product> The product from where simulation has to be fetched
##                  <netsimVersion> The netsimversion to be picked
##
##     Example : ./getNetsimNexusPatchList.pl -p NetsimPatches_CDB -d 18.0.0 -v R29E
##
##     Dependencies : 1. The simulations has to be present in the cifwk portal
##
##     NOTE: 1. The module is at present applicable for OSSRC-CDB
##
##
####################################################################################

use strict;
use warnings;
use Getopt::Std;

my %options=();
getopts("d:p:v:", \%options);

if ( !(defined($options{d}) && defined($options{p}) && defined($options{v})) ){
    print "Usage: $0 -d drop -p product -v version\n";
    exit 1;
}

my $drop=$options{d};
my $product=$options{p};
my $netsimVersion=$options{v};

#
#----------------------------------------------------------------------------------
# Generate config file using the json file obtained from the portal
#----------------------------------------------------------------------------------
#

my $netsimHome="/netsim/";
my $SIMDEP_CONTENTS_PATH="$netsimHome/simdepContents";
my $PATCH_LIST_FILE="$SIMDEP_CONTENTS_PATH/patchList.txt";
my $NETSIM_LIST_FILE="$SIMDEP_CONTENTS_PATH/netsimList.txt";
`rm -rf $SIMDEP_CONTENTS_PATH`;
`mkdir -p $SIMDEP_CONTENTS_PATH`;

my $Request="https://cifwk-oss.lmera.ericsson.se/getDropContents/?drop=$drop&product=$product&pretty=true";
`curl -ssl -3 --request GET \"$Request\" > $SIMDEP_CONTENTS_PATH/fileList.json`;

if ((`cat $SIMDEP_CONTENTS_PATH/fileList.json | grep error`)){
    print "ERROR: Failed to fetch files from product - $product and drop - $drop\n";
    exit(202);
}

my @names=`cat $SIMDEP_CONTENTS_PATH/fileList.json|grep "name"`;
my @urls=`cat $SIMDEP_CONTENTS_PATH/fileList.json|grep "url"`;
my @packagetypes=`cat $SIMDEP_CONTENTS_PATH/fileList.json|grep "type"`;

my @artifactslist = ();
my @urllist = ();
my @packagelist = ();

foreach my $i(0..$#names) {
    $artifactslist[$i]=&getValue($names[$i]);
    $urllist[$i]=&getValue($urls[$i]);
    $packagelist[$i]=&getValue($packagetypes[$i]);
}

sub getValue {
    my $arg=$_[0];
    my @keyvalue=split( /: /, $arg);
    my $value=$keyvalue[1];
    chomp($value);
    $value =~ s/^\s+|\s+$|,|"//g;
    return $value;
}

open CONFIG, "> $PATCH_LIST_FILE" or die "Could not open $PATCH_LIST_FILE";
open NETSIMCONFIG, "> $NETSIM_LIST_FILE" or die "Could not open $NETSIM_LIST_FILE";
foreach my $i(0..$#artifactslist) {
    if ( $packagelist[$i] eq "zip" && $artifactslist[$i] =~ m/$netsimVersion/ ){
        if ( $artifactslist[$i] =~ m/1_19089-FAB760956Ux/ ){
            print NETSIMCONFIG "$urllist[$i]\n";
        }
        else {
            print CONFIG "$urllist[$i]\n";
        }
    }
}
close(CONFIG);
close(NETSIMCONFIG);
