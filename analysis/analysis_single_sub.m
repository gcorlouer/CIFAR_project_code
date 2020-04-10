% This script is the pipeline for one subject 

% TODO: 

%       Check preproc data
%       Try Itzik methodolgy for envelope extraction
%       Experiment different window size, time segments etc
%       Compare EEGlab filtering with pop_firws
%       Ringing removal of the filtered signal (Dechevigne)
%       Try downsampling
%       Descriptive statistics script
%       Pairwise conditional GC
%       What is the directionality of mvgc?
%       Estimate uncertainty in DFC and statistical significance
%       Build better functions: filtering, epoching, importing data

% Warning : DARE WARNING: large relative residual = 2.364349e-05 ????

%% Parameters


% Filtering

if ~exist('filterOrder', 'var') filterOrder = 100; end 
if ~exist('fcut1','var') fcut1 = 60; end
if ~exist('fcut2','var') fcut2 = 80; end
if ~exist('fstop1','var') fstop1 = 57; end % Stopband attenuation
if ~exist('fstop2','var') fstop2 = 82; end
if ~exist('fs','var') fs = 500;  end
if ~exist('fn','var') fn  = fs/2; end % Nyquist
if ~exist('f','var') f = [0 fstop1 fcut1 fcut2 fstop2 fn]/fn; end % Bandpass frequency with attenuation
if ~exist('a','var') a = [0 0 1 1 0 0]; end % Filter moving average components
if ~exist('w','var') w   = [700 1 700]; end % Weights of the filter 
if ~exist('fbin','var') fbin = 1024; end% Number of frequency bins
if ~exist('Band','var') Band = [fcut1 fcut2]; end

% Epoching 

if ~exist('trange','var') trange = [10 50]; end % Time series range
if ~exist('wsize','var') wsize = [0 2]; end % Epoch size
if ~exist('wstep','var') wstep = 0.1; end % Step between epochs
if ~exist('multitrial','var') multitrial = true; end

% ROI select for dFC

if ~exist('nROI','var') nROI = 2; end % Number of ROI to pick for analysis
if ~exist('inter','var') inter = false; end % Inter or intra relation for dFC analysis

%% Import preprocessed data and pick chans/ROIs


[fname, fpath, dataset] = CIFAR_filename('preproc', true); 

EEG = pop_loadset(fname, fpath);

% Select time window 

EEG = pop_select(EEG, 'time', trange);

% Pick random ROIs  

msize = numel(EEG.preproc.igoodROI);
ROIs = EEG.preproc.igoodROI(randperm(msize, nROI));

[X, EEG] = pick_chan(EEG, ROIs);

fs = EEG.srate;

%% Anatomical representation



%% Envelope extraction

% Bandpass filter
bpFilt   = firgr(filterOrder, f, a, w, 'minphase');

% Magnitude response
hfvt = fvtool(bpFilt,'Fs', fs,...
              'MagnitudeDisplay', 'Magnitude (dB)',...
              'legend','on');
legend(hfvt,'Min Phase');

% Impulse response
fvtool(bpFilt, 'Fs', fs, ...
              'Analysis', 'Impulse', ...
              'legend', 'on', ...
              'Arithmetic', 'fixed');
          
% Extract envelope from hilbert transform on filtered data
[envelope, tsdata_filt] = tsdata2env(X, bpFilt);

trange = 1:5000; chanum= 1;
plot_envelope(tsdata_filt,envelope,trange, chanum, fs)

% Assign in new EEG structure
EEG_envelope = EEG;
EEG_envelope.data = envelope;

EEG_filt = EEG;
EEG_filt.data = tsdata_filt;

close all

%% Epoching 

outEEG_env = eeg_regepochs(EEG_envelope, 'recurrence', wstep, 'limits', wsize); % Epoch envelope
epochEEG_filt = eeg_regepochs(EEG_filt, 'recurrence', wstep, 'limits', wsize); % Epoch filtered data
epochEEG = eeg_regepochs(EEG, 'recurrence', wstep, 'limits', wsize); % Epoch initial data

% Extract epoched time series
epochedEnvelope = outEEG_env.data; 
epochedTsdata_filt = epochEEG_filt.data;
epochX = epochEEG.data;

%% VAR modeling

tic 
[VARmodel, VARmoest] = VARmodeling(epochedEnvelope, 'momax', 30, 'mosel', 2, 'multitrial', multitrial);
toc

%% SS modeling 

% Envelope

tic
[SSmodel_envelope, moest_envelope] = SSmodeling(epochedEnvelope, 'mosel', 2, 'multitrial', multitrial);
toc

% ECoG

tic
[SSmodel_ecog, moest_envelope] = SSmodeling(epochX, 'mosel', 2, 'multitrial', multitrial);
toc

%% Directed funcitonal connectivity (DFC) 

% Pick channels indexes
ichanROI1 = EEG.picks.ROI2chans{1};
ichanROI2 = EEG.picks.ROI2chans{2};

% New channel indexes (for reduced time series)
ichan1 = 1:size(ichanROI1,2);
ichan2 = size(ichanROI1,2)+1:size(X,1);


% DFC on Envelope
[DFC_env, sDFC_env, mDFC_env] = directFC(SSmodel_envelope, ichan1, ichan2, Band, ...
    'multitrial', multitrial, 'inter', true, 'temporal', true, 'ichan', ichan2);

% DFC on ECoG

[DFC_ecog, sDFC_ecog, mDFC_ecog] = directFC(SSmodel_ecog, ichan1, ichan2, Band, ...
    'multitrial', multitrial, 'inter', true, 'temporal', false, 'ichan', ichan2);

% Pairwise CGC



% Plot DFC of ECoG and envelope for multitrial data

hold on
plot(DFC_env)
plot(DFC_ecog)
legend('Envelope', 'ECoG')
xlabel('time (sec)')
ylabel('MVGC')
DFC_title = ['comparison of DFC on HFB envelope with signal ROI', ...
    num2str(ROIs(1)), '-', num2str(ROIs(2))];
title(DFC_title)
hold off

