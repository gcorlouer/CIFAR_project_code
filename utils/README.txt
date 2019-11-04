
Assumed directory/file structure for CIFAR data
-----------------------------------------------

<data_root>/CIFAR/
    iEEG_10/
        figures/                                             --- generated MATLAB figures
        fsbrains/                                            --- SUMA brain stuff
        presented stimuli/                                   --- JPEG images
        subjects/
            <sub1>/
                Brain/
                    SUMAInflatedSrf.mat
                    SUMAPialSrf.mat
                    SUMAprojectedElectrodes.mat
                    ROI_map.mat                              --- generated (set-up)
                    channel_names.mat                        --- generated (set-up)
                EEGLAB_datasets/
                    raw_signal/
						<EEGLAB .set and .fdt files>
                        nopreproc/
							(non-preprocessed .mat files)    --- generated (set-up)
                        <preproc1>/
							(preprocessed .mat files)        --- generated (preprocessing)
                        <preproc2>/
                        ........../
                        <preprocn>/
                    bipolar_montage/
						(similar to raw_signal/)
            <sub2>/
            ....../
            <subn>
    metadata/
		metadata.mat


Set-up (one-time tasks):
------------------------

* Make sure lates MVGC toolbox is installed

* Amend 'startup.m' for MVGC location, EEGLAB location, and  <data_root> location.
  Make sure 'startup.m' is run.

* Run 'metadata/make_metadata':

>> clear
>> make_metadata

This generates 'metadata.mat' in <data_root>/CIFAR/

 * (Guillaume) To load EEGlab structure and map channels on the struct: 
>> subject='AnRa'
>> BP=false
>> chan_map_SUMA 

* (Lionel) Run metadata/make_SUMA_channel_map for each subject:

>> clear
>> subject = 'AnRa';
>> make_SUMA_channel_maps

This generates 'SUMA_ROI_map.mat' and 'SUMA_electrode_names.mat' in
<data_root>/CIFAR/iEEG_10/AnRa/Brain/. Do the same for other subjects (at
least if the SUMA maps are available).

* Link ROI and channel maps. In Bash shell, cd to <data_root>/CIFAR/iEEG_10/AnRa/Brain/
  and then run at the command prompt:

$ ln -s SUMA_ROI_map.mat ROI_map.mat
$ ln -s SUMA_electrode_names.mat channel_names.mat


* Create non-preprocessed .mat files from EEGLAB data sets, using 'make_nopreproc.m':

>> clear
>> BP = false;
>> subject = 'AnRa';
>> make_nopreproc

This creates a 'nopreproc' directory containing .mat files corresponding to EEGLAB
datasets, in <data_root>/CIFAR/iEEG_10/AnRa/EEGLAB_datasets/raw_signal/. Do the same
for BP = true (bipolar montage) and other subjects.


Preprocessing:
--------------

Have a look at 'preproc/do_preproc.m'. Then, e.g.,

>> clear
>> BP = false;
>> subject = 'AnRa';
>> dataset = 'freerecall_rest_baseline_1_preprocessed'; % dataset name
>> pford = 8;          % polynomial detrend order
>> lnfreqs = [60 180]; % line-noise frequencies to remove
>> do_preproc

and follow the prompts. This will perform a sliding-window polynomial detrend (similar
to a highpass filter, but better), and remove line noise at 60Hz and 180Hz. It will create
a directory called 'preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1' in
<data_root>/CIFAR/iEEG_10/AnRa/EEGLAB_datasets/raw_signal/, and a .mat file corresponding
to the dataset 'freerecall_rest_baseline_1_preprocessed' (the 'w5s0.1' indicates that
a default sliding window of 5 seconds, sliding by 0.1 seconds, was used).

Note: there is also a highpass Butterwortyh filter option, but the polynomial detrend seems
to do the job better... best not to use both at once.
---------------------------------------
*Select channels
>> BP = false;
>> subject = 'AnRa';
>> schans=-6; %select ROI
>> badchans=0; 
>> [chans,chanstr,channames,ogchans] = select_channels(BP,subject,dataset,schans,badchans,[]) %Select unknown chans
>> badchans=chans; %define bad chans
>> goodchans = get_goodchans(BP,subject,dataset,badchans); 

*Select badchans 
badchans=0;
[chans,chanstr,channames,ogchans] = select_channels(BP,subject,dataset,schans,badchans,verb)
what is ogchans?
Analysis:
---------

Have a browse through the 'analysis' sub-directory of this code. The 'inspect_*.m' scripts
allow examination of specified data segments, the effects of preprocessing, etc. E.g., try

>> clear
>> BP = false;
>> subject = 'AnRa';
>> dataset = 'freerecall_rest_baseline_1_preprocessed'; % dataset name
>> schans = -6;    % select SUMA ROI 6
>> tseg = [23 27]; % select time segment from 23 to 27 seconds
>> ppdir = 'preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; % preprocessed
>> inspect_time_series

In the 'sliding_window' sub-directory, there are various scripts for performing statistical
analysis on specified sliding windows of selected channels, ROIs, etc. E.g., try:

>> clear
>> BP = false;
>> subject = 'AnRa';
>> name = 'freerecall_rest_baseline_1_preprocessed'; % dataset name
>> schans = -6;         % select SUMA ROI 6
>> ppdir = 'nopreproc'; % no preprocessing
>> fignum = 1;
>> sliding_meanstd

Now try instead with

>> ppdir = 'preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';

and you can compare the results of the preprocessing on the mean and standard deviation of the
data in ROI 6.

To save the figures, run with

>> figsave = true;

You should see the output:

Figure file: '<data_root>/iEEG_10/figures/sliding_meanstd_AnRa_freerecall_rest_baseline_1_preprocessed_nopreproc.fig'

at the end. You can then get an image of the figure by running:

>> print_fig('<data_root>/CIFAR/iEEG_10/figures/sliding_meanstd_AnRa_freerecall_rest_baseline_1_preprocessed_nopreproc.fig','png')

You should see the output:

Image file: '<data_root>/CIFAR/iEEG_10/figures/sliding_meanstd_AnRa_freerecall_rest_baseline_1_preprocessed_nopreproc.png'

You can also do 'pdf', 'jpeg', etc.

To examine ROIs, run e.g.,

>> rmap = get_ROI_map('AnRa')

rmap =

  struct with fields:

         subject: 'AnRa'
          nchans: 128
    chan2ROIname: {128x1 cell}
        ROInames: {23x1 cell}
           nROIs: 23
        chan2ROI: [128x1 double]
       ROI2chans: {23x1 cell}
       nROIchans: [23x1 double]

>> rmap.ROInames{6}

ans =

    'ctx-rh-fusiform'

>> rmap.ROI2chans{6}

ans =

    90    91    92    93    94    95    96    97    98   109   110   118

and so on.


Have fun!

Lionel
