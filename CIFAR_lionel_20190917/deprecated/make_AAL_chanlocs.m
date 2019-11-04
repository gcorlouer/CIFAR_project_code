function make_AAL_chanlocs(BP,subject,name)

global CIFAR_root;

fprintf('\nLoading ECoG ... ');
[EEG,filename,filepath] = load_EEG(BP,subject,name);
fileroot = fullfile(filepath,filename);
fprintf('loaded ''%s''\n',fileroot);

nchans = length(EEG.chanlocs);
coords = zeros(nchans,3);
for i = 1:nchans
	coords(i,1) = EEG.chanlocs(i).X;
	coords(i,2) = EEG.chanlocs(i).Y;
	coords(i,3) = EEG.chanlocs(i).Z;
end

fprintf('\nSaving channel coordinates temporary file ... ');
save(fullfile(tempdir,'coords.mat'),'coords','-v6'); % for R.matlab
fprintf('done\n');

Rcmd = ['Rscript ' fullfile(CIFAR_root,'preproc','make_AAL_chanlocs.R')];
fprintf('\nRunning ''%s'' ...\n\n',Rcmd);
[status,cmdout] = system(Rcmd,'-echo');
assert(status == 0,'Something bad happened');

fprintf('Reading temporary CSV file ... ');
% T = readtable(fullfile(tempdir,'labels.csv'));
% chan.coords = coords;
% chan.label = T.(3);
% chan.distance = T.(2);
fid = fopen(fullfile(tempdir,'labels.csv'));
chan = textscan(fid,'"%d",%f,%s','HeaderLines',1);
fclose(fid);

fprintf('done\n');

chanfile = [fileroot '_AAL_chanlocs.mat'];
fprintf('\nSaving channel locations file ''%s'' ... ',chanfile);
save(chanfile,'chan');
fprintf('done\n');
