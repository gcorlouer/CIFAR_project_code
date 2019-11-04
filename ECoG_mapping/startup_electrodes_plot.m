%% This file add the relevant path to plot EcoG electrodes.
global ecog_map_root; 
ecog_map_root= fileparts(mfilename('fullpath')); % directory containing this file

%Add all subfolder to the current path
addpath(ecog_map_root);
addpath(genpath(fullfile(ecog_map_root,'ECoG_mapping')));
addpath(genpath(fullfile(ecog_map_root,'code')));
global subject_path;
subject_path='/its/home/gc349/CIFAR_guillaume/CIFAR_data/CIFAR/iEEG_10/subjects';