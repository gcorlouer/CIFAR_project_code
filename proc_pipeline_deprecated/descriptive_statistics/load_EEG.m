function [EEG,filename,filepath] = load_EEG(BP,subject,name)

[filename,filepath] = CIFAR_filename(BP,subject,name);

EEG = pop_loadset('filename',[filename '.set'],'filepath',filepath);
