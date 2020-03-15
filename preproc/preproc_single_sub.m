%% Preprocess single sub
%
% TODO : Update EEGlab version https://sccn.ucsd.edu/wiki/How_to_download_EEGLAB
%        Find out another way to do automated cleaning https://github.com/sccn/clean_rawdata/blob/master/pop_clean_rawdata.m
%        Try ICA and see if it helps      
%        Experiment different polynomial order fit and compare them
%        Inspect preproc and detrending
%        Denoise data

%% Import data (EEG structure with SUMA and data)

subject = 'AnRa'; task = 'rest_baseline_1';

[fname, fpath, dataset] = CIFAR_filename('BP', false); 

EEG = pop_loadset(fname, fpath);

%% Inspect time series 
% Beware that channel names on figure are meaningless here

pop_eegplot(EEG);
% saveas(gcf,fullfile(fig_path_root, 'AnRa_raw_bp_rest1_allchans_100s.png'))
%% Line noise removal (only on raw data)



%% Drop bad channels 

dropChan = [1, 40:50, 59, 60, 61]; % Hyppocampal and unknown regions

[X, timeStamp, EEG] = remove_badChan(EEG, dropChan);

% Data shape for NoiseTool is time*sample*trials

x = permute(X,[2 1]);

%% Robust detrending 

% Run time ~ 30 sec
order = 10; 
w = []; 
basis= 'sinusoids';  % sinusoid seems to work better
thresh = []; 
niter = []; 
wsize = 10*500;

tic
y = nt_detrend(x,order,w,basis,thresh,niter,wsize);
toc

Y = permute(y, [2 1]);
EEG.data = Y;
%% Robust outliers detection and removal
% Run time 10 mn

tic
w = [];
thresh = 3;
niter = 4;
[w,y] = nt_outliers(y,w,thresh,niter);
toc 


Y = permute(y,[2 1]);
EEG.data = Y;
nchan = EEG.nbchan;  nobs = nchan*EEG.pnts;
noutl = sum(w(:)==0) * 100/nobs; % Percentage of outliers

%% ICA ? 



%% Inspec preproc
tsNopreproc = X;
tsPreproc = Y;
[preprocStat, nopreprocStat] = inspectPreproc(tsPreproc, tsNopreproc, timeStamp);

nogauss_preproc = size(find(preprocStat.kurt > 1),1);
nogauss_nopreproc = size(find(nopreprocStat.kurt > 1),1);

[smean_np,kmean_np,po1mean_np,po2mean_np] = slidingGaussianity(tsNopreproc,timeStamp);
[smean_pp,kmean_pp,po1mean_pp,po2mean_pp] = slidingGaussianity(tsPreproc,timeStamp);

gaussdevPreproc = size(find(kmean_pp > 1),1); % measure deviation from gaussianity
gaussdevNopreproc = size(find(kmean_np > 1),1);
%% Autospectral density


%% Save preprocessed data 

parentFolder = fullfile(cfsubdir, subject, 'EEGLAB_datasets','bipolar_montage');
preprocfolder = ['preproc_','_noBadchans_detrend_pforder_' ... 
    num2str(order) basis '_rmv_outlier_' num2str(thresh) 'std'];
mkdir(parentFolder, preprocfolder)

fname2save = fname;
fpath2save = fullfile(cfsubdir, subject, 'EEGLAB_datasets', ... 
    'bipolar_montage', preprocfolder);
EEG = pop_saveset(EEG , 'filename', fname2save, 'filepath', fpath2save, ... 
    'savemode', 'onefile' );