function [X,ts,filepath,filename] = get_EEG_tsdata(BP,subject,dataset,ppdir,bigfile)

[filepath,filename] = CIFAR_filename(BP,subject,dataset);
fname = fullfile(filepath,ppdir,[filename '.mat']);

X  = [];
ts = [];
if bigfile
	X = matfile(fname,'Writable',false);
	ts = X.ts; % we need to load this to find segment... hopefully enough memory!
else
	load(fname);
end
