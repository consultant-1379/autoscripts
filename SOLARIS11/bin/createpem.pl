#!/usr/bin/perl

#This is a more reliable file to parse certs
use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;

sub main {
    my ($certFile, $certDir);

    my $result = GetOptions(
        "certfile=s" => \$certFile,
        "certdir=s" => \$certDir,
    );

    #print "Certfile: " . $certFile . "\n";

    open INPUTFILEDESCRIPTOR, $certFile or die "Cannot open $certFile: $!";
    my $currentData;
    my $count = 1;
    my $file;

    while ( my $line = <INPUTFILEDESCRIPTOR> ) {
        # information for the cert we are currently parsing out
        if ($line =~ /^Bag Attributes$/) {
            # starting new cert - do we have a previous cert to write to a file?
            if ( defined($currentData)) {
                if ($count == 1) { $file = "key.pem"; }
                elsif ($count == 2) { $file = "cert.pem"; }
                else { $file = "cacert.pem"; }
                open OUTPUTFILE, ">>$certDir/$file" or die "Could not open $certDir/$file: $!";
                print OUTPUTFILE $currentData;
                close OUTPUTFILE;
                #print "\n\nCURRENT DATA " . $count . " :\n\n " . $currentData;
                $currentData = "";
                $count++;
            }
        }
        $currentData .= $line;
    }
    # duplicate code - should be in a function
    open OUTPUTFILE, ">>$certDir/$file" or die "Could not open $certDir/$file: $!";
    print OUTPUTFILE $currentData;
    close OUTPUTFILE;
    #print "LAST CURRENT DATA " . $count . ": " . $currentData;
}

main;
