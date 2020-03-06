%% Preprocess single sub
%
% TODO : Update EEGlab version https://sccn.ucsd.edu/wiki/How_to_download_EEGLAB
%        Find out another how to do automated cleaning https://github.com/sccn/clean_rawdata/blob/master/pop_clean_rawdata.m
%        Try ICA and see if it helps      
%        Experiment different polynomial order fit and compare them
%        Code a function to load unpreproc and preproc data
%% Import data (EEG structure with SUMA and data)
subject = 'AnRa';
task = 'rest_baseline_1';

[X, ts, EEG, filepath, filename, chanstr] = import_ecogdata(subject, 'ppdir','nopreproc');

%% Inspect time series 

pop_eegplot(EEG);

%% Drop bad channels 

dropChan = [1, 40:50, 59, 60, 61]; % Hyppocampal and unknown regions

[X, EEG] = remove_badChan(EEG, dropChan);

% Data shape for NoiseTool is time*sample*trials

x = permute(X,[2 1]);

%% Robust detrending 

% Run time 30 sec
order = 10; 
w = []; 
basis= 'sinusoids';  % sinusoid seems to work better
thresh = []; 
niter = []; 
wsize = 10*500;

tic
y = nt_detrend(x,order,w,basis,thresh,niter,wsize);
toc

%% Robust outliers detection and removal
% Run time 10 mn

tic
w = [];
thresh = 3;
niter = 4;
[w,y_clean] = nt_outliers(y,w,thresh,niter);
toc 

noutl = sum(w(:)==0);

%% ICA ? 



%% Gaussianity

y_clean = permute(y_clean,[2 1]);

[smean,kmean,po1mean,po2mean] = slidingGaussianity(X,ts);

%% Autospectral density



%% SS modeling on sliding window (for stationarity)



%% Save preprocessed data 


