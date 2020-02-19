%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map channels to SUMA ROIs, store in EEG struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set 'BP', 'subject'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% From mapping file
%
% chan2elec(i)     - SUMA electrode label number of i-th channel (zero if not found)
% nROI             - number of ROIs in SUMA map
% chan2ROI(i)      - SUMA ROI number of i-th channel
% chan2ROIname{i}  - SUMA ROI name   of i-th channel
% ROInames{k}      - name of k-th SUMA ROI
% nROIchans(k)     - number of channels in k-th SUMA ROI
% ROI2chans{k}(i)  - i-th channel in k-th SUMA ROI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sm = get_SUMA_map(subject);

filepath = CIFAR_filename(BP,subject);

s = dir([filepath filesep '*.set']);

for i = 1:length(s) 
	sdataset = s(i).name;
    slpitDataset = strsplit(sdataset,'_');
    task = slpitDataset{3};
    if task(1) == 'r'
        task = strjoin(slpitDataset(3:5),'_');
    elseif task(1:2) == 'st'
        task = strjoin(slpitDataset(3:4),'_');
    else 
    end
	try % catch out-of-memory errors, etc.
		[filepath,filename] = CIFAR_filename(BP,subject,task);
		EEG = pop_loadset('filename',[filename '.set'], ... 
            'filepath',filepath, 'loadmode', 'info' );
	catch problem
		fprintf(2,'\n*** DATASET LOAD FAILED (%s) ***\n\n',problem.identifier);
		continue
	end

	cm.channames    = cell(1,EEG.nbchan);
	cm.chan2elec    = zeros(1,EEG.nbchan);
	cm.ROInames     = unique(sm.aparcaseg.bestLabel.labels);
	cm.nROIs        = length(cm.ROInames)+1;
	cm.ROInames{cm.nROIs} = 'unknown';
	cm.chan2ROI     = zeros(1,cm.nROIs);
	cm.chan2ROIname = cell(1,EEG.nbchan);
    if BP == 0 
        for i = 1:EEG.nbchan
            cm.channames{i} = EEG.chanlocs(i).labels;
            for j = 1:sm.nElec
                if strcmp(cm.channames{i},sm.elecNames{j})
                    cm.chan2elec(i) = j;
                    cm.chan2ROIname{i} = sm.aparcaseg.bestLabel.labels{j};
                    continue
                end
            end
            % if still zero, it wasn't found
            if cm.chan2elec(i) == 0
                cm.chan2ROI(i)     = cm.nROIs;              % last ROI is 'unknown'
                cm.chan2ROIname{i} = cm.ROInames{cm.nROIs}; %  'unknown'
            else
                for k = 1:cm.nROIs % for each ROI
                    if strcmp(cm.chan2ROIname{i},cm.ROInames{k})
                        cm.chan2ROI(i) = k;
                        continue;
                    end
                end
            end
        end
    else
        for i = 1:EEG.nbchan
            cm.channames{i} = strsplit(EEG.chanlocs(i).labels, '-'); % Get first chaname in paired chans
                for j = 1:sm.nElec
                    if strcmp(cm.channames{i}{1},sm.elecNames{j});
                        cm.chan2elec(i) = j;
                        cm.chan2ROIname{i} = sm.aparcaseg.bestLabel.labels{j};
                        continue
                    end
                end
            cm.channames{i} = EEG.chanlocs(i).labels ; 

                % if still zero, it wasn't found
                if cm.chan2elec(i) == 0
                    cm.chan2ROI(i)     = cm.nROIs;              % last ROI is 'unknown'
                    cm.chan2ROIname{i} = cm.ROInames{cm.nROIs}; %  'unknown'
                else
                    for k = 1:cm.nROIs % for each ROI
                        if strcmp(cm.chan2ROIname{i},cm.ROInames{k})
                            cm.chan2ROI(i) = k;
                            continue;
                        end
                    end
                end
        end
    end
	cm.ROI2chans = cell(cm.nROIs,1);
	cm.nROIchans = zeros(1,cm.nROIs,1);
	for k = 1:cm.nROIs % for each ROI
		cm.ROI2chans{k} = find(cm.chan2ROI == k); % channels matching ROI
		cm.nROIchans(k) = length(cm.ROI2chans{k});
	end

	cm.chansbyROI = horzcat(cm.ROI2chans{:}); % concatenate!y = cell2mat(cm.ROI2

	EEG.SUMA = cm;
	EEG = rmfield(EEG,{'data','times'}); % don't need these in here

	fname = fullfile(filepath,[filename '.mat']);
	fprintf('Saving SUMA channel map with EEG data ''%s'' ... ',fname);
	save(fname,'-v7.3','EEG');
	fprintf('done\n\n');

end
