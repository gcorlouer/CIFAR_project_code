% Load simulated data
% TODO ask via email if can reject manually data segment


fname = 'SNN_M3_C3_321a_S10000_CC200_d8.0_I20_mw0.20_md4.0ms_cw0.40_cd45.0ms_x4.30_10000Hz_70s.mat';
LFP_sim = load(fullfile(sim_dir, fname ));

% Build EEG structure from dataset

EEG.setname = [];
EEG.filename = fname;
EEG.filepath = sim_dir;
EEG.xmin = 0;
EEG.xmax = 70.0001;
EEG.pnts = size(LFP_sim.V,2);
EEG.nbchan = size(LFP_sim.V,1);
EEG.trials = 1;
EEG.srate = LFP_sim.fs;
EEG.times = LFP_sim.t;
EEG.data = LFP_sim.LFP;
EEG.potential = LFP_sim.V;
EEG.chanlocs = [];
EEG.epoch = [];
EEG.event = [];
EEG.reject = [];
EEG.stats = [];
EEG.icaact = [];
EEG.icawinv = [];
EEG.icasphere = [];
EEG.icaweights = [];
EEG.icachansind = [];

% Reject transient behavior

X = EEG.data;
rejSec = 5; % number of seconds to reject
nrejSample = rejSec*EEG.srate; % Number of samples to reject
rejectEpoch = 1:nrejSample; % epoched to reject
X(:, rejectEpoch) = [];
EEG.data = X; 
EEG.potential(:, rejectEpoch) = [];
EEG.times(:, rejectEpoch) = [];
EEG.pnts = size(X,2);
EEG.xmax = EEG.xmax - rejSec;
% Resample and save new dataset

EEG = eeg_checkset(EEG);
EEG = pop_resample(EEG, 500);
CURRENTSET = 1;
ALLEEG(CURRENTSET) = EEG;

pop_eegplot(EEG, 'reject', 0)
