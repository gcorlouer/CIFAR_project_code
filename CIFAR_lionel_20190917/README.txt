
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


Set-up (one-time tasks) - best to use 'neocortex' for sleep data!:
------------------------------------------------------------------

* Make sure lates MVGC toolbox is installed

* Amend 'startup.m' for MVGC location, EEGLAB location, and  <data_root> location.
  Make sure 'startup.m' is run.

* Run 'preproc/make_metadata':

>> clear
>> make_metadata

This generates 'metadata.mat' in <data_root>/CIFAR/metadata

* Run 'preproc/configure_data' for each subject:

>> clear
>> subject = 'AnRa';
>> BP = false; % raw data: set to 'true' for bipolar montage data
>> configure data

This does the following:

1) Strips the actual time series data out of the EEGLAB dataset, and saves it in a .mat file
   under the 'nopreproc' directory.

2) Creates a '.mat' file with the same name as the EEGLAB dataset, containing the EEG structure.
   The EEG structure is now without the time series data, but contains a new field called 'SUMA'
   which contains all the channel mapping information.

Preprocessing - best to use 'neocortex' for sleep data!:
--------------------------------------------------------

Have a look at 'preproc/do_preproc.m'. Then, e.g. (parameters below are the defaults anyway)

>> clear
>> BP = false;
>> subject = 'AnRa';
>> name = 'freerecall_rest_baseline_1_preprocessed'; % dataset name
>> pford = 8;          % polynomial detrend order
>> lnfreqs = [60 180]; % line-noise frequencies to remove
>> do_preproc

and follow the prompts. This will perform a sliding-window polynomial detrend (similar
to a highpass filter, but better), and remove line noise at 60Hz and 180Hz. It will create
a directory called 'preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1' in
<data_root>/CIFAR/iEEG_10/AnRa/EEGLAB_datasets/raw_signal/, and a .mat file corresponding
to the dataset 'freerecall_rest_baseline_1_preprocessed' (the 'w5s0.1' indicates that
a default sliding window of 5 seconds, sliding by 0.1 seconds, was used).

Note 1: there is also a highpass Butterworth filter option, but the polynomial detrend seems
to do the job better... don't use both at once.

Note 2: proprocessing can take a while... there is a batch file 'batch/preproc.sh' to help
automate the task (edit the 'BP' and 'subject' shell variables).

Note 3: If you are going to use, say, the 'preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1' data as
your basic preprocessed data, it saves a lot of typing to soft-link it to a directory called
just 'preproc'. To do this, first cd to the
<data_root>/CIFAR/iEEG_10/<subject>/EEGLAB_datasets/raw_signal/ directory, and at the shell prompt,
type:

$ ln -s preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1 preproc

Have fun!

Lionel
