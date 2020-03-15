% This script is the pipeling for one subject 
% TODO: computing time for SS modeling. check that good ROIs are picked up
%       mean and std for SS model+ statistical inference
%       DFC analysis
%       write function for envelope extraction with nice filtering method
%       write an option to plot mosvc selection on SSmodeling    

subject = 'AnRa';

%% Import preprocessed data and pick chans/ROIs

subject = 'AnRa'; task = 'rest_baseline_1'; order = 10; thresh = 3; basis = 'sinusoids';
preproc = ['preproc_','_noBadchans_detrend_pforder_' ... 
    num2str(order) basis '_rmv_outlier_' num2str(thresh) 'std'];

[fname, fpath, dataset] = CIFAR_filename('preproc', preproc); 

EEG = pop_loadset(fname, fpath);

% Select random ROIs 
nROI = 2; 
ROIs = [8 23];
% If want random ROIs:
% msize = numel(EEG.preproc.igoodROI);
% ROIs = EEG.preproc.igoodROI(randperm(msize, nROI));

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
trange = 1:5000; chanum= 4;

plot_envelope(tsdata_filt,envelope,trange, chanum, fs)

EEG_envelope = EEG;
EEG_envelope.data = envelope;

%% Epoching 
wsize = [0 5];
wstep = 1;
outEEG_env = eeg_regepochs(EEG_envelope, 'recurrence', wstep, 'limits', wsize); 

epochedEnvelope = outEEG_env.data; 

%% SS modeling 
% Might take 5 minuts for 45 channels 42 epochs
tic
[SSmodel_envelope, moest] = SSmodeling(epochedEnvelope);
toc

%% DFC 

[DFC_envelope, DFC_ecog, mDFC_envelope, mDFC_ecog, m_sDFC_ecog] = ... 
    directFC(SSmodel_envelope, SSmodel_ecog, connect, CROI, fs, intBand);