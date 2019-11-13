#!/bin/bash

# Source condor-ce environment
[ -f /usr/share/condor-ce/condor_ce_env_bootstrap ] &&
   . /usr/share/condor-ce/condor_ce_env_bootstrap

/usr/local/bin/bosco-cluster-remote-hosts.py

