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

# Edit these
BP="false"
subject="AnRa"

dataset="freerecall_rest_baseline_1_preprocessed"
logfile=$currdir/$scriptname\_BP\_$BP\_$dataset
matcmds="BP = $BP; subject = '$subject'; dataset = '$dataset'; verb = 1; do_preproc; quit"
cd $codedir && $runmatlab -r "$matcmds" > $logfile\_a.log < /dev/null 2>&1 &

dataset="freerecall_rest_baseline_2_preprocessed"
logfile=$currdir/$scriptname\_BP\_$BP\_$dataset
matcmds="BP = $BP; subject = '$subject'; dataset = '$dataset'; verb = 1; do_preproc; quit"
cd $codedir && $runmatlab -r "$matcmds" > $logfile\_a.log < /dev/null 2>&1 &

dataset="freerecall_stimuli_1_preprocessed"
logfile=$currdir/$scriptname\_BP\_$BP\_$dataset
matcmds="BP = $BP; subject = '$subject'; dataset = '$dataset'; verb = 1; do_preproc; quit"
cd $codedir && $runmatlab -r "$matcmds" > $logfile\_a.log < /dev/null 2>&1 &

dataset="freerecall_stimuli_2_preprocessed"
logfile=$currdir/$scriptname\_BP\_$BP\_$dataset
matcmds="BP = $BP; subject = '$subject'; dataset = '$dataset'; verb = 1; do_preproc; quit"
cd $codedir && $runmatlab -r "$matcmds" > $logfile\_a.log < /dev/null 2>&1 &
