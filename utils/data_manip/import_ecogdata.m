function [X, ts, EEG, filepath,filename,chanstr]=import_ecogdata(subject, varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import CIFAR time series 

%%% Input 
% BP : bipolar montage, default = true
% task : default = 'rest_baseline_1', 'rest_baseline_2', 'sleep',
% "stimuli_1", "stimuli_2"
% tseg : time segment, default = [] all ts
% badchans : default = [], take all chans, badchans = 0 for good chans
% ds : default = 1, no downsmpling
% ppdir : def = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; 
% 'nopreproc' unpreprocessed data
% chans : chan to select, def = [] all chans

%%% Output
% X time series
% ts time stamp
% EEG sutrcutre
% chanstr list of selected chans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBP = true;
defaultTask = 'rest_baseline_1';
defaultSchans = 0; % 0 takes all chans, negative integer picks ROI, positive picks channel
defaultTseg = []; % length of time series
defaultBadchans = []; % 0 for only good chans, [] for all chans
defaultDs = 1; % no downsampling
defaultPpdir = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; % preproc data, otherwise just no preproc
defaultChans = []; 

p = inputParser;

addRequired(p,'subject');
addParameter(p, 'BP', defaultBP, @islogical);
addParameter(p, 'task', defaultTask,@isvector);
addParameter(p, 'tseg', defaultTseg);
addParameter(p, 'schans', defaultSchans, @isscalar);
addParameter(p, 'chans', defaultChans, @isvector);
addParameter(p, 'badchans', defaultBadchans);
addParameter(p, 'ds', defaultDs, @isscalar);
addParameter(p, 'ppdir', defaultPpdir, @isvector);

parse(p, subject, varargin{:});

% Load EEG info
[EEG,filepath,filename] = get_EEG_info(p.Results.BP, p.Results.subject, p.Results.task);
% Select chans
[chans,chanstr, ~,~] = select_channels(p.Results.BP, p.Results.subject, ... 
    p.Results.task, p.Results.schans, p.Results.badchans);
% load time series
[X,ts,~] = load_EEG(p.Results.BP, p.Results.subject, p.Results.task, ... 
    p.Results.ppdir,chans,p.Results.tseg,p.Results.ds);
% Append time series to EEG structure
EEG.data = X;

end



