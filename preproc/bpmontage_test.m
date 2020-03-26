%% Bipolar derivation script
% TODO : -Resampling: how does it work ?
%        -Remove DC how does it work ?
%        -Generalise to other subjects
%% Import data (EEG structure with SUMA and data)

subject = 'AnRa'; task = 'rest_baseline_1';

[fname, fpath, dataset] = CIFAR_filename('BP', false); 

EEG = pop_loadset(fname, fpath);

outFileName =[subject '_freerecall_' task '_preprocessed_BP_montage.set'];

% Wanting pairing: 

[fname, fpath, dataset] = CIFAR_filename('BP', true); 

EEG_BP = pop_loadset(fname, fpath);

nchan = EEG_BP.nbchan; 

%% Channels to be paired

rawChan = EEG.SUMA.channames; bpChan = EEG_BP.SUMA.channames;

outEEG_BP = EEG_BP;

for i= 1 : EEG_BP.nbchan
    k = strfind(bpChan{i}, '-');
	if ~ isempty(k)
        bpchanName = strsplit(bpChan{i}, '-');
        chan1 = bpchanName{1};
        chan2 = bpchanName{2};
        ichan1 = find(contains(EEG.SUMA.channames, chan1)) ;
        ichan2 = find(contains(EEG.SUMA.channames, chan2)) ;
        outEEG_BP.data(i,:) = EEG.data(ichan1(1),:) - EEG.data(ichan2(1),:) ;
    elseif ismember(bpChan{i},'EMG')
        continue
    elseif ismember(bpChan{i},'CREF')
        continue
    elseif isempty(k)
        ichan = find(contains(EEG.SUMA.channames, bpChan{i}));
        outEEG_BP.data(i,:) = EEG.data(ichan(1),:);
    end
end

    

%% Re-referenceing:
%==========================================================================
% Remove DC from each electrode:
outEEG_BP = pop_rmbase(outEEG_BP,[EEG.times(1) EEG.times(end)]);
%==========================================================================

%% Save set:

outdir = fullfile(cfsubdir, subject, 'EEGLAB_datasets', 'bipolar_montage');
outEEG_BP = pop_saveset( outEEG_BP,  'filename', outFileName, 'filepath', outdir);
disp('data saved')
%% Maybe useful later but might take time to run

%       [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
% % Resample to 500 Hz:
% outEEG_BP = pop_resample(outEEG_BP,500);

% [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
% eeg_checkset()

% %% Anatomical location (native space):
% 
% % load individual brain:
% S_brain = struct;
% S_brain.plotsurf = 'pial';
% S_brain.layout = 'compact';
% S_brain.surfacealpha = 1;
% S_brain.meshdir = fullfile(cfsubdir, subject, 'brain');
% 
% elocDir = fullfile(S_brain.meshdir);
% load(fullfile(elocDir,'electrodes.mat'));

% %% Define hippocampus channel: 
% 
% chanLabels = {EEG.chanlocs.labels};
% hippocampus_channel_idx = find(strncmpi({EEG.chanlocs.labels},'RDh',3));
% hippocampus_channel = chanLabels(hippocampus_channel_idx);
% 
% % Remove non-channels:
% rm_idx=zeros(EEG.nbchan,1);
% for i = 1:EEG.nbchan
% tmp = EEG.chanlocs(i).labels;
% if strcmp(tmp(1),'C')
%     rm_idx(i)=1;
%     disp(tmp);
% end
% end
% 
% EEG = pop_select(EEG,'nochannel',find(rm_idx));
% [ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
% eeglab redraw;        
% 
% aux_channels=[find(strcmpi({EEG.chanlocs.labels},'EOG'))
% find(strcmpi({EEG.chanlocs.labels},'ECG'))
% find(strcmpi({EEG.chanlocs.labels},'EKG'))
% find(strcmpi({EEG.chanlocs.labels},'TRIG'))
% find(strcmpi({EEG.chanlocs.labels},'PR'))
% find(strcmpi({EEG.chanlocs.labels},'OSAT'))
% find(strcmpi({EEG.chanlocs.labels},'EVENT'));
% find(strncmpi({EEG.chanlocs.labels},'RDh',3))];
% 
% % Load electrode locations: (MNI)
%% Prepare crap 

% % Compute EMG indicator: (Schomburg et al, 2014; Watson et al. 2016);
% forder_BP=330;
% [EEG_highpass,~,b] = pop_firws(EEG, 'fcutoff', 100, 'ftype', 'highpass', ...
%     'wtype', 'hamming', 'forder', forder_BP,  'minphase', 0);
% X = EEG_highpass.data;
% EMG = zeros(size(X,2),1);
% win = 20; % 40 ms window
% winstep = 1;
% parfor i = 1:size(X,2)
%     if i <= (win/2)
%         r = corrcoef(X(:,1:i+(win/2))','rows','pairwise');
%     elseif i >= size(X,2)-(win/2)
%         r = corrcoef(X(:,i-(win/2):end)','rows','pairwise');
%     else
%         r = corrcoef(X(:,i-(win/2):i+(win/2))','rows','pairwise');
%     end
%     r(find(tril(r,0)))=nan;
%     EMG(i) =  nanmean(nanmean(r));
%     if rem((i/size(X,2)*100),10)==0, fprintf('\n %d percent completed \n',i/size(X,2)*100); end
% end
% clear EEG_highpass
% % Compute common cortical average 
% EEG.data(end+1,:) = EMG;
% EEG.nbchan = size(EEG.data,1);
% EEG.chanlocs(end+1).labels = 'EMG';        
% 
% EEG_clean=EEG;
% CREF = mean(EEG_clean.data, 2);
% EEG.data(nchan+1,:) = CREF;
% EEG.nbchan = size(EEG.data,1);
% EEG.chanlocs(end+1).labels = 'CREF';