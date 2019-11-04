function [EEG,filename,filepath] = load_EEG(BP,subject,dataset)

[filepath,filename] = CIFAR_filename(BP,subject,dataset);

EEG = pop_loadset('filename',[filename '.set'],'filepath',filepath);
