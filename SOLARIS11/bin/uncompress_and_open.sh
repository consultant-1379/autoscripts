#!/bin/bash
SIMULATION="$1"
MML=".uncompressandopen $SIMULATION force"
su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_shell"

