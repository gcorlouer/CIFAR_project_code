% Load Data:
clear all
close all
clc;
addpath('D:\Itzik_DATA\MATLAB ToolBoxes\eeglab13_4_4b'); eeglab; % Don't change
rmpath(genpath('D:\Itzik_DATA\MATLAB ToolBoxes\chronux_2_12'));
addpath('D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts');
addpath('D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts\Ripples_analysis\');
addpath(genpath('D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts\General Functions'));

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

subjects={'DiAs','AnRi','NaGe','BeFe','LuFl','AnRa','TeBe','JuRo','SoGi','NeLa','KaWa','JuTo','FaWa','ArLa','KiAl','JoGa','ArLa2'};

for initials = subjects(end)
    initials = cell2mat(initials);
    
    % load individual brain:
    S_brain = struct;
    S_brain.plotsurf = 'pial';
    S_brain.layout = 'compact';
    S_brain.surfacealpha = 1;
    S_brain.meshdir = 'D:\FreeSurfer\Data\SUMA_meshData\';

    for run=['1' '2']
        close all;
        clearvars -except subjects initials run ALLEEG EEG SUMAsrf S_brain
        ALLEEG=[]; EEG=[]; CURRENTSET=1;
        
        maindir=['D:\ECoG\Free_Recall_RAWDATA\' initials];
        outdir=['D:\ECoG\Free_Recall_RAWDATA\' initials '\EEGLAB_DATASETS_BP\WholeRun\']; % ADJUST OUTDIR
        mkdir(outdir);
        
        % Load Configuration file;
        load(fullfile(maindir,[initials '_configuration_file.mat']));
        outFileName =[initials '_freerecall_' run '_preprocessed_BP_montage.set'];
        
        if iscell(edfFileName.(['run' run]))
            for i=1:numel(edfFileName.(['run' run]))
                filename=edfFileName.(['run' run]){i};
                % Load EDF:
                if strcmpi(filename(end-2:end),'edf')
                    EEG = pop_biosig(filename,'importevent','off');
                elseif strcmpi(filename(end-2:end),'set')
                    [EEG] = pop_loadset('filename', filename);
                else
                    disp('Wrong file name...');
                end
                [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', outFileName(1:end-4));
                eeglab redraw;
            end
            EEG = pop_mergeset( ALLEEG, [1:numel(edfFileName.(['run' run]))], 0);
            EEG = eeg_checkset( EEG );
            EEG.setname='Merged';
            [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
            eeglab redraw
        else
            filename=edfFileName.(['run' run]);
            % Load EDF:
            if strcmpi(filename(end-2:end),'edf')
                EEG = pop_biosig(filename,'importevent','off');
            elseif strcmpi(filename(end-2:end),'set')
                [EEG] = pop_loadset('filename', filename);
            else
                disp('Wrong file name...');
            end
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', outFileName(1:end-4));
            eeglab redraw;
        end
        
        if exist('run_commands','var')
            for k=1:numel(run_commands)
                eval(run_commands{k});
            end
        end
        
        % Define TRIG Channel (if needed):
        EEG=pop_chanedit(EEG,'changefield',{TRIG_channel 'labels' 'TRIG'});
        EEG=pop_chanedit(EEG,'changefield',{ECG_channel 'labels' 'ECG'});
        if exist('EOG_channel','var')
            EEG=pop_chanedit(EEG,'changefield',{EOG_channel 'labels' 'EOG'});
        end
        
        if sum(strcmpi({EEG.chanlocs.labels},'TRIG'))>1
            disp('Channels:')
            find(strcmpi({EEG.chanlocs.labels},'TRIG'))
            error('******** There are 2 TRIG channels! ********');
        end
        
        % Anatomical location (native space):
        elocDir = fullfile(S_brain.meshdir,initials);
        load(fullfile(elocDir,'electrodes.mat'))
        
        % Define hippocampus channel:        
        hippocampus_channels;
        
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
            find(strcmpi({EEG.chanlocs.labels},'EVENT'))];
        
        % Load electrode locations: (MNI)
        EEG=ReadElectrodeCoord(EEG,channel_location_file,maindir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
        eeglab redraw;
        
        % Plot FS Brain (optional):
%         [S_brain,H_brain,SUMAsrf] = plot_FS_brain('cvs_avg35_inMNI152',S_brain);
%         elocDir=fullfile(S_brain.meshdir,initials);
%         load(fullfile(elocDir,'SUMAprojectedElectrodes.mat'))
%         ch_labels=[SUMAprojectedElectrodes.elecNames];
%         ePlot=ch_labels;
%         ePlot1=ch_labels(multiStrFind(ch_labels,'Grid')|multiStrFind(ch_labels,'Grd'));
%         ePlot2=setdiff(ch_labels,ePlot1);
%         eSize=1.5; % 1.5 radius in mm
%         eColor=[0 0 0];
%         textFlag=1;
%         S_brain=plot_Fs_electrode(initials,H_brain,S_brain,SUMAsrf,elocDir,ch_labels,eColor,[],eSize,textFlag,'gouraud','top');
        
        % Plot MNI Brain to verify:
        figure; hold on;
        mesh='D:\ECoG\Free_Recall_RAWDATA\MNI_brain_mesh\MNI_brain_downsampled.mat';
        headplot_itzik(EEG.data,fullfile(maindir,[initials '_spline_file_MNIbrain.spl']),[],'meshfile',mesh,'electrodes','on', ...
            'title',initials,'labels',1,'cbar',0, 'maplimits','absmax','colormap',colormap('Gray'));
        alpha(0.15)
        
        %==================================================================
        % Load excluded channels list (from the common reference analysis):
        load([maindir '\EEGLAB_DATASETS_RMR\' initials '_excluded_channels_unified.mat']);
        good_channels=setdiff(1:EEG.nbchan,excluded_channels_unified,'stable');
        FS_channels = find(ismember({EEG.chanlocs.labels},electrodes.elecNames));
        good_channels = intersect(good_channels, FS_channels);
        
        if ~strcmpi(initials,'LuFl')
            channelFSlabel = {};
            numOfvoxels = [];
            for k = good_channels
                ch_label = EEG.chanlocs(k).labels;
                electrodeInd = find(strcmpi(electrodes.elecNames,ch_label));
                if isempty(electrodeInd)
                    channelFSlabel{k}='N/A';
                    continue;
                end
                currentROI = electrodes.aparcaseg.bestLabel.labels(electrodeInd);
                channelFSlabel(k,1) = currentROI;
                numOfvoxels(k) = electrodes.aparcaseg.bestLabel.NumOfVoxel(electrodeInd);
            end
            
            % Find cortical contacts (optional):
            % cortical_channels = find(multiStrFind(channelFSlabel,'ctx')&~multiStrFind(channelFSlabel,'unknown'));
            
            % Compute EMG indicator: (Schomburg et al, 2014; Watson et al. 2016);
            forder_BP=330;
            [EEG_highpass,~,b] = pop_firws(EEG, 'fcutoff', 100, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', forder_BP,  'minphase', 0);
            X = EEG_highpass.data(good_channels,:);
            EMG = zeros(size(X,2),1);
            win = 20; % 40 ms window
            winstep = 1;
            parfor i = 1:size(X,2)
                if i <= (win/2)
                    r = corrcoef(X(:,1:i+(win/2))','rows','pairwise');
                elseif i >= size(X,2)-(win/2)
                    r = corrcoef(X(:,i-(win/2):end)','rows','pairwise');
                else
                    r = corrcoef(X(:,i-(win/2):i+(win/2))','rows','pairwise');
                end
                r(find(tril(r,0)))=nan;
                EMG(i) =  nanmean(nanmean(r));
                if rem((i/size(X,2)*100),10)==0, fprintf('\n %d percent completed \n',i/size(X,2)*100); end
            end
            clear EEG_highpass
            EEG.data(end+1,:) = EMG;
            EEG.nbchan = size(EEG.data,1);
            EEG.chanlocs(end+1).labels = 'EMG';
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
            EEG = eeg_checkset( EEG );
            aux_channels=union(aux_channels,find(strcmpi({EEG.chanlocs.labels},'EMG')));
            
            
            % Compute common cortical average after 60Hz removal:
            notchFreqs=[60 120 180];
            filterWidth=1.5; % Hz
            EEG_clean=EEG;
            for f=notchFreqs
                % Adjust the filter order manually! (use the EEGLAB menu to calculate the order)
                [EEG_clean,~,b] = pop_firws(EEG_clean, 'fcutoff', [f-filterWidth f+filterWidth], 'ftype', 'bandstop', 'wtype', 'hamming', 'forder', 1100);
                figure; freqz(b);
            end
            CREF = robustMean(EEG_clean.data(good_channels,:),1,5);
            clear EEG_clean
            EEG.data(end+1,:) = CREF;
            EEG.nbchan = size(EEG.data,1);
            EEG.chanlocs(end+1).labels = 'CREF';
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
            EEG = eeg_checkset( EEG );
            aux_channels=union(aux_channels,find(strcmpi({EEG.chanlocs.labels},'CREF')));
        end
        
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
end


