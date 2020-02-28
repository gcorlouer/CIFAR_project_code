%% load EEG info without loading time series
%% Parameters
% BP=0 or 1; bipolar montage or raw
% subject: subject name
% task : 'rest_baseline_1', 'rest_baseline_2','sleep', 'stimuli_1', 'stimuli_2';
function [EEG,filepath,filename] = get_EEG_info(BP,subject,task)

[filepath,filename] = CIFAR_filename(BP,subject,task);
fname = fullfile(filepath,[filename '.mat']);
EEG = [];
load(fname);