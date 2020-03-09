% This script is the pipeling for one subject 
% TODO: computing time for SS modeling. check that good ROIs are picked up
%       mean and std for SS model+ statistical inference
%       DFC analysis
%       import preprocessed data
%       write function for envelope extraction with nice filtering method
%       write an option to plot mosvc selection on SSmodeling    

subject = 'AnRa';

%% Import preprocessed data and pick chans/ROIs

%[X, ts, EEG, filepath,filename,chanstr]=import_ecogdata(subject, ... 
%    'tseg', [], 'badchans', [], 'schans', 0);
%y_clean = permute(y_clean,[2 1]);

EEG.data = y_clean;

% Select ROIs 
nROI = 4; 
msize = numel(EEG.preproc.igoodROI);
ROIs = EEG.preproc.igoodROI(randperm(msize, nROI));

[X, EEG] = pick_chan(EEG, ROIs);

%% Anatomical representation



%% Envelope extraction



%% Epoching 

outEEG = eeg_regepochs(EEG, 'recurrence', 1, 'limits', [0 5]); 
X = outEEG.data; 

%% SS modeling 
% Might take 5 minuts for 45 channels 42 epochs
tic
[SSmodel_envelope, moest] = SSmodeling(X, ts);
toc

%% DFC 

[DFC_envelope, DFC_ecog, mDFC_envelope, mDFC_ecog, m_sDFC_ecog] = ... 
    directFC(SSmodel_envelope, SSmodel_ecog, connect, CROI, fs, intBand);