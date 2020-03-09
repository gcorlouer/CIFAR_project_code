%% Preprocess single sub
%
% TODO : Update EEGlab version https://sccn.ucsd.edu/wiki/How_to_download_EEGLAB
%        Find out another way to do automated cleaning https://github.com/sccn/clean_rawdata/blob/master/pop_clean_rawdata.m
%        Try ICA and see if it helps      
%        Experiment different polynomial order fit and compare them
%        Inspect preproc and detrending
%        Denoise raw data

%% Import data (EEG structure with SUMA and data)
% subject = 'AnRa'; task = 'rest_baseline_1';

[fname, fpath, dataset] = CIFAR_filename(); 

EEG = pop_loadset(fname, fpath);

%% Inspect time series 

pop_eegplot(EEG);

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

%% Robust outliers detection and removal
% Run time 10 mn

tic
w = [];
thresh = 3;
niter = 4;
[w,y] = nt_outliers(y,w,thresh,niter);
toc 

nchan = EEG.nbchan;  nobs = nchan*EEG.pnts;
noutl = sum(w(:)==0) * 100/nobs; % Percentage of outliers

%% ICA ? 



%% Inspec preproc

[newStat, oldStat] = inspectPreproc(tsdata, ts_detrend, timeStamp);

Y = permute(y,[2 1]);

[smean,kmean,po1mean,po2mean] = slidingGaussianity(Y,timeStamp);

%% Autospectral density


%% Save preprocessed data 

