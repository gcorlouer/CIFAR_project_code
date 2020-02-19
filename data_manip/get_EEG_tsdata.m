function [X,ts,filepath,filename] = get_EEG_tsdata(BP,subject,task,ppdir, bigfile)

if nargin < 5 bigfile=false; end

[filepath,filename] = CIFAR_filename(BP,subject,task)
fname = fullfile(filepath,ppdir,[filename '.mat']);

X  = [];
ts = [];
if bigfile
	X = matfile(fname,'Writable',false);
	ts = X.ts; % we need to load this to find segment... hopefully enough memory!
else
    data=load(fname);
    if  ppdir(1)=='n' %nopreproc
        X=data.tseries;
        ts=data.tstep;
    else 
        X=data.X;
        ts=data.ts;
    end
end
