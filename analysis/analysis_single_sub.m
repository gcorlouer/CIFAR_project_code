% This script is the pipeling for one subject 
% TODO: computing time for SS modeling. check that good ROIs are picked up
%       mean and std for SS model+ statistical inference
%       DFC analysis    

subject = 'AnRa';

%% Import preprocessed data (select ROIs)
[X, ts, EEG, filepath,filename,chanstr]=import_ecogdata(subject, ... 
    'tseg', [], 'badchans', [], 'schans', 0);

%% Anatomical representation

%% Time series visualisation
pop_eegplot(EEG);

%% Epoching 

outEEG=eeg_regepochs(EEG, 'recurrence', 1, 'limits', [0 5]); 
X = outEEG.data; 

%% SS modeling 

[SSmodel, moest] = SSmodeling(X, ts);

%% DFC 
