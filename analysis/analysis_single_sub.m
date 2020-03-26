    % This script is the pipeling for one subject 
% TODO: 

%       mean and std for SS model on epoched data
%       Experiment different window size, time segments etc
%       Compare EEGlab filtering with pop_firws
%       DFC analysis
%       Ringing removal of the filtered signal (Dechevigne)
%       Try downsampling
%       Descriptive statistics script
%       Plot spectral radius of epoched data
%       Write DFC functions in a better manner
%       Pairwise GC
%       What is the directionality of mvgc?
%       Intra DFC

%% Import preprocessed data and pick chans/ROIs

subject = 'AnRa'; task = 'rest_baseline_1'; order = 10; thresh = 3; basis = 'sinusoids';
trange = [10 30];

preproc = ['preproc_','_noBadchans_detrend_pforder_' ... 
    num2str(order) basis '_rmv_outlier_' num2str(thresh) 'std'];

[fname, fpath, dataset] = CIFAR_filename('preproc', preproc); 

EEG = pop_loadset(fname, fpath);
EEG = pop_select(EEG, 'time', trange);

% Select random ROIs 
% nROI = 2; 
% ROIs = [6 11];
% If want random ROIs:
msize = numel(EEG.preproc.igoodROI);
ROIs = EEG.preproc.igoodROI(randperm(msize, nROI));

[X, EEG] = pick_chan(EEG, ROIs);

%% Anatomical representation



%% Envelope extraction

% TODO
% Suggestion also plot ideal filter response and phast response
% Design FIR bandpass minimum phase filter
% Code better utility function to plot envelope against signal

filterOrder = 100; fcut1 = 60; fcut2 = 80; 
fstop1 = 57; fstop2 = 82; fs = 500;  fn  = fs/2; 

f = [0 fstop1 fcut1 fcut2 fstop2 fn]/fn; 
a = [0 0 1 1 0 0]; w   = [700 1 700]; 

bpFilt   = firgr(filterOrder, f, a, w, 'minphase');
hfvt = fvtool(bpFilt,'Fs', fs,...
              'MagnitudeDisplay', 'Magnitude (dB)',...
              'legend','on');
legend(hfvt,'Min Phase');

fvtool(bpFilt, 'Fs', fs, ...
              'Analysis', 'Impulse', ...
              'legend', 'on', ...
              'Arithmetic', 'fixed');
          
% Extract envelope from hilbert transform on filtered data

[envelope, tsdata_filt] = tsdata2env(X, bpFilt);
trange = 1:5000; chanum= 1;

plot_envelope(tsdata_filt,envelope,trange, chanum, fs)

EEG_envelope = EEG;
EEG_envelope.data = envelope;

EEG_filt = EEG;
EEG_filt.data = tsdata_filt;

close all

%% Epoching 

wsize = [0 2];
wstep = 1;

outEEG_env = eeg_regepochs(EEG_envelope, 'recurrence', wstep, 'limits', wsize); 
epochEEG_filt = eeg_regepochs(EEG_filt, 'recurrence', wstep, 'limits', wsize);
epochEEG = eeg_regepochs(EEG, 'recurrence', wstep, 'limits', wsize);

epochedEnvelope = outEEG_env.data; 
epochedTsdata_filt = epochEEG_filt.data;
epochX = epochEEG.data;

%% VAR modeling

tic 
[VARmodel, VARmoest] = VARmodeling(epochedEnvelope, 'momax', 30, 'mosel', 2, 'multitrial', false);
toc

%% SS modeling 

% Envelope

tic
[SSmodel_envelope, moest_envelope] = SSmodeling(epochedEnvelope, 'mosel', 2, 'multitrial', false);
toc

% ECoG

tic
[SSmodel_ecog, moest_envelope] = SSmodeling(epochedEnvelope, 'mosel', 2, 'multitrial', false);
toc

%% DFC 
ichanROI1 = EEG.picks.ROI2chans{1};
ichanROI2 = EEG.picks.ROI2chans{2};

ichan1 = 1:size(ichanROI1,2);
ichan2 = size(ichanROI1,2)+1:size(X,1);

fs = EEG.srate;
fbin = 1024; % can maybe change the default
Band = [fcut1 fcut2];

multitrial = false;

% DFC on envelope

[DFC_envelope, mDFC_env] = directFC(SSmodel_envelope, ichan1, ichan2, multitrial);

% sDFC on ecog and integration over specific band

[sDFC_ecog, intDFC_ecog, mean_intDFC_ecog] = intDirectFC(SSmodel_ecog, ichan1, ... 
    ichan2, multitrial, fs, fbin, Band);

% Plot DFC for multitrial data

hold on
plot(DFC_envelope)
plot(intDFC_ecog)
legend('Envelope', 'ECoG')
xlabel('time (sec)')
ylabel('MVGC')
DFC_title = ['comparison of DFC on HFB envelope with signal ROI', ...
    num2str(ROIs(1)), '-', num2str(ROIs(2))];
title(DFC_title)
hold off
