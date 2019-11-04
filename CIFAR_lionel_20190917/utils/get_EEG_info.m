function [EEG,filepath,filename] = get_EEG_info(BP,subject,dataset)

[filepath,filename] = CIFAR_filename(BP,subject,dataset);
fname = fullfile(filepath,[filename '.mat']);
EEG = [];
load(fname);
