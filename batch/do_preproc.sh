#!/bin/bash

# base name of this script (without extension)
scriptname=$(basename $0 .sh)

echo -e "\n*** Running batch script '"$scriptname"' ***\n"

# path to Matlab code directory
codedir=$LOCALREPO/matlab/ncomp/CIFAR

# current directory (the directory this script is run in - log files will go here)
currdir=$(pwd -P)

# Restrict cores?
if [ -n "$1" ]; then
	tset="taskset -c $1"
fi

# Matlab invocation
runmatlab="nohup nice $tset matlab -nojvm -nodisplay"

datatype="raw"
subject="AnRa"

dataset="freerecall_rest_baseline_1_preprocessed"

logfile=$currdir/$scriptname\_$datatype\_$dataset
matcmds="BP = false; subject = '$subject'; dataset = '$dataset'; pford = 8; do_preproc; quit"
cd $codedir && $runmatlab -r "$matcmds" > $logfile\_a.log < /dev/null 2>&1 &

matcmds="BP = false; subject = '$subject'; dataset = '$dataset'; lnfreqs = [60 180]; do_preproc; quit"
cd $codedir && $runmatlab -r "$matcmds" > $logfile\_b.log < /dev/null 2>&1 &

matcmds="BP = false; subject = '$subject'; dataset = '$dataset'; pford = 8; lnfreqs = [60 180]; do_preproc; quit"
cd $codedir && $runmatlab -r "$matcmds" > $logfile\_c.log < /dev/null 2>&1 &
