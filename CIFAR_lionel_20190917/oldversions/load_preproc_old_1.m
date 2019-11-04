function [X,FS,filepath,filename] = load_preproc(BP,subject,name,ppdir)

[filepath,filename] = CIFAR_filename(BP,subject,name);

filepath = fullfile(filepath,ppdir);
fname = fullfile(filepath,[filename,'.mat']);

X = [];
FS = [];
load(fname);
