% Load Data:
% clear all
% close all
% clc;
% addpath('D:\Itzik_DATA\MATLAB ToolBoxes\eeglab13_4_4b'); eeglab; % Don't change
% rmpath(genpath('D:\Itzik_DATA\MATLAB ToolBoxes\chronux_2_12'));
% addpath('D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts');
% addpath('D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts\Ripples_analysis\');
% addpath(genpath('D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts\General Functions'));

% [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%subjects={'DiAs','AnRi','NaGe','BeFe','LuFl','AnRa','TeBe','JuRo','SoGi','NeLa','KaWa','JuTo','FaWa','ArLa','KiAl','JoGa','ArLa2'};


% load individual brain:
S_brain = struct;
S_brain.plotsurf = 'pial';
S_brain.layout = 'compact';
S_brain.surfacealpha = 1;
S_brain.meshdir = fullfile(cfsubdir, subject, 'brain');

for run=['1' '2']
% import raw data

% Load Configuration file;
load(fullfile(maindir,[initials '_configuration_file.mat']));
outFileName =[initials '_freerecall_' run '_preprocessed_BP_montage.set'];


% Anatomical location (native space):
elocDir = fullfile(S_brain.meshdir,initials);
load(fullfile(elocDir,'electrodes.mat'))

% Define hippocampus channel: 
chanLabels = {EEG.chanlocs.labels};
hippocampus_channel_idx = find(strncmpi({EEG.chanlocs.labels},'RDh',3));
hippocampus_channel = chanLabels(hippocampus_channel_idx);

% Remove non-channels:
rm_idx=zeros(EEG.nbchan,1);
for i=1:EEG.nbchan
tmp=EEG.chanlocs(i).labels;
if strcmp(tmp(1),'C')
    rm_idx(i)=1;
    disp(tmp);
end
end
EEG = pop_select(EEG,'nochannel',find(rm_idx));
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;        

aux_channels=[find(strcmpi({EEG.chanlocs.labels},'EOG'))
find(strcmpi({EEG.chanlocs.labels},'ECG'))
find(strcmpi({EEG.chanlocs.labels},'EKG'))
find(strcmpi({EEG.chanlocs.labels},'TRIG'))
find(strcmpi({EEG.chanlocs.labels},'PR'))
find(strcmpi({EEG.chanlocs.labels},'OSAT'))
find(strcmpi({EEG.chanlocs.labels},'EVENT'));
find(strncmpi({EEG.chanlocs.labels},'RDh',3));

% Load electrode locations: (MNI)
EEG=ReadElectrodeCoord(EEG,channel_location_file,maindir);
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;

%% Bipolar montage:
%==========================================================================
XYZ = []; 
good_ch_labels={EEG.chanlocs(good_channels).labels};
for i=1:numel(good_ch_labels)
XYZ(i,:) = electrodes.coord.afniXYZ(strcmpi(electrodes.elecNames,good_ch_labels{i}),:);
end        

counter=1;
sig=[]; ref=[];
new_labels={};
clc;
% STEP 1: all contacts in the hippocampal depth electrode are paired with a nearby WM contact -

if ~isempty(hippocampus)
if isempty(WM_ref), error('Missing a WM contact!'); end
% White matter reference contact:
channel2 = WM_ref;
cnum2 = find(strcmpi({EEG.chanlocs.labels},WM_ref)); % index within the EEG dataset 

% hippocampal contacts:
hipp_array = good_ch_labels(multiStrFind(good_ch_labels,hippocampus(isstrprop(hippocampus, 'alpha')))); % get all good DH contacts
hipp_array = setdiff(hipp_array,channel2);

for i = 1:numel(hipp_array)
    channel1 = hipp_array{i}; 
    cnum1 = find(strcmpi({EEG.chanlocs.labels},channel1)); % index within the EEG dataset 
    if str2num(channel1(isstrprop(channel1, 'digit'))) >= 8, continue; end % skip the superficial hippocampus-electrode contacts (contact #8 and above)
    % Usually, Da/Dh/Dp contacts  1-5 are located within the
    % hippocampus (since they are the deepest contacts)               

    % Calculate distance in mm (for sanity check):
    tmp1 = find(strcmpi(good_ch_labels,channel1));
    tmp2 = find(strcmpi(good_ch_labels,channel2));                
    d = sqrt(sum((bsxfun(@minus,XYZ(tmp1,:),XYZ(tmp2,:)).^2),2));

    % Sanity Check:
    if ~ismember(cnum2,good_channels)
        error(sprintf('\n --> Wrong Channel: %s \n Please Verify... \n',channel2));
    end
    fprintf('\n *** Channel: %s [%3d] - %s [%3d]  (%.2f mm) *** \n',channel1,cnum1,channel2,cnum2,d);
    new_labels{cnum1}=sprintf('%s-%s',channel1,channel2);
    sig(counter)=cnum1;
    ref(counter)=cnum2;
    counter=counter+1;
end
else
fprintf('\n --> No hippocampal channels, moving on... \n');
end

% STEP 2: process all remaining channels -   

for i=1:numel(good_ch_labels)     

channel1=good_ch_labels{i};
cnum1=find(strcmpi({EEG.chanlocs.labels},channel1)); % index within the EEG dataset    

current_array=good_ch_labels(multiStrFind(good_ch_labels,channel1(isstrprop(channel1, 'alpha'))));
if ismember(cnum1,sig), continue; end                       
if ismember(cnum1,ref), continue; end % to use only unique channels
% Choose:
current_array=setdiff(current_array,{EEG.chanlocs([sig, ref]).labels}); % only unique pairs      
% current_array=setdiff(current_array,{EEG.chanlocs(sig).labels});        % allow duplicates 
current_array=setdiff(current_array,channel1);

if isempty(current_array)
    fprintf('\n --> Skipping Channel: %s    (last contact in the strip)\n',channel1);
    continue;
end

% Find the cloest channel on the strip to serve as reference:
dist=[];
for k=1:numel(current_array)
    dist(k)=sqrt(sum((bsxfun(@minus,XYZ(i,:),XYZ(strcmpi(good_ch_labels,current_array{k}),:)).^2),2));
end
[d,idx]=min(dist);
channel2=current_array{idx};
cnum2=find(strcmpi({EEG.chanlocs.labels},channel2));

% exclude pairs that are >20 mm apart from each other
if  d>20 
    fprintf('\n --> Skipping Channel: %s [%3d] - %s [%3d]  (%.2f mm) \n',channel1,cnum1,channel2,cnum2,d);
    continue;
end

% Sanity Check:
if ~ismember(cnum2,good_channels)
    error(sprintf('\n --> Wrong Channel: %s \n Please Verify... \n',channel2));
end
fprintf('\n *** Channel: %s [%3d] - %s [%3d]  (%.2f mm) *** \n',channel1,cnum1,channel2,cnum2,d);
new_labels{cnum1}=sprintf('%s-%s',channel1,channel2);
sig(counter)=cnum1;
ref(counter)=cnum2;
counter=counter+1;
end

figure; 
scatter(sig,ref,30,'.k')
xlabel('Sig ch.'); ylabel('Ref ch.');
title('Indices of all electrode pairs')

%% Re-referenceing:
reref_data=zeros(numel(sig),EEG.pnts);
for i=1:numel(sig)
reref_data(i,:)=EEG.data(sig(i),:)-EEG.data(ref(i),:);
fprintf('\n Subtracting Electrodes: %3d - %3d \n',sig(i),ref(i));
end

for i=1:EEG.nbchan
if ismember(i,sig)
    EEG=pop_chanedit(EEG,'changefield',{i 'labels' new_labels{i}});
    EEG=pop_chanedit(EEG,'changefield',{i 'type' 'signal'});
    EEG.data(i,:)=reref_data(sig==i,:);
end
if ismember(i,aux_channels)
    EEG=pop_chanedit(EEG,'changefield',{i 'type' 'aux'});
end
end

EEG = pop_select(EEG,'channel',[aux_channels; sig']);
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw;

%==========================================================================
% Remove DC from each electrode:
EEG = pop_rmbase(EEG,[EEG.times(1) EEG.times(end)]);
EEG.setname=[outFileName(1:end-4) ' - DC removed'];
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw;
%==========================================================================

% Resample to 500 Hz:
EEG = pop_resample(EEG,500);
% Remove line noise using the new EEGLAB FIR filter:
good_channels=find(strcmpi({EEG.chanlocs.type},'signal'));
%figure; spectopo(EEG.data(good_channels,:),0,EEG.srate,'percent',10,'title','Before Removing Line Noise');
notchFreqs=[60 120 180];
filterWidth=1.5; % Hz
EEG_clean=EEG;
for f=notchFreqs
% Adjust the filter order manually! (use the EEGLAB menu to calculate the order)
[EEG_clean,~,b] = pop_firws(EEG_clean, 'fcutoff', [f-filterWidth f+filterWidth], 'ftype', 'bandstop', 'wtype', 'hamming', 'forder', 1100);
figure; freqz(b);
end        
%figure; spectopo(EEG_clean.data(good_channels,:),0,EEG.srate,'percent',10,'title','After Removing Line Noise');

% Store DATA:
EEG=EEG_clean;
EEG.setname=[outFileName(1:end-4) ' - Filtered'];
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw;
eegplot(EEG.data(good_channels,:),'color','off','srate',EEG.srate,'winlength',15,'limits',[EEG.times(1) EEG.times(end)])


%% Save set:

EEG.setname=outFileName(1:end-4);
EEG = pop_saveset( EEG,  'filename', outFileName, 'filepath', outdir);
disp('data saved')
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

eegplot(EEG.data(strcmpi({EEG.chanlocs.type},'signal'),:),'color','off','srate',EEG.srate,'winlength',15,'limits',[EEG.times(1) EEG.times(end)])

end



