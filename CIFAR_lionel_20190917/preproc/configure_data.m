%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map channels to SUMA ROIs, store in EEG struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set 'BP', 'subject'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% First make matfiles containing everything except the time series data!
% Save the actual data in a 'nopreproc' subdirectory.
%
% Then copy relevant information and build channel mappings into
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
	m = strfind(sdataset,'_');
	j = strfind(sdataset,'_');
	if isempty(j), continue; end
	j = j(1);
	k = strfind(sdataset,'.set');
	if isempty(k), continue; end
	k = k(1);
	dataset = sdataset(j+1:k-1);
	try % catch out-of-memory errors, etc.
		[filepath,filename] = CIFAR_filename(BP,subject,dataset);
		EEG = pop_loadset('filename',[filename '.set'],'filepath',filepath);
	catch problem
		fprintf(2,'\n*** DATASET LOAD FAILED (%s) ***\n\n',problem.identifier);
		continue
	end

	% Save actual time-series data in 'nopreproc' subdirectory

	X  = double(EEG.data);
	ts = double(EEG.times)/1000; % seconds!

	[status,msg] = mkdir(filepath,'nopreproc');
	assert(status == 1,msg);
	fname = fullfile(filepath,'nopreproc',[filename '.mat']);
	fprintf('\nSaving unpreprocessed time-series data in ''%s'' ... ',fname);
	save(fname,'-v7.3','X','ts');
	fprintf('done\n');

	EEG = rmfield(EEG,{'data','times'}); % don't need these in here anymore

	% Build SUMA channel mapping

	cm.channames    = cell(1,EEG.nbchan);
	cm.chan2elec    = zeros(1,EEG.nbchan);
	cm.ROInames     = unique(sm.aparcaseg.bestLabel.labels);
	cm.nROIs        = length(cm.ROInames)+1;
	cm.ROInames{cm.nROIs} = 'unknown';
	cm.chan2ROI     = zeros(1,cm.nROIs);
	cm.chan2ROIname = cell(1,EEG.nbchan);
	for i = 1:EEG.nbchan
		cm.channames{i} = EEG.chanlocs(i).labels;
		for j = 1:sm.nElec
			if strcmp(cm.channames{i},sm.elecNames{j});
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

	cm.ROI2chans = cell(cm.nROIs,1);
	cm.nROIchans = zeros(1,cm.nROIs,1);
	for k = 1:cm.nROIs % for each ROI
		cm.ROI2chans{k} = find(cm.chan2ROI == k); % channels matching ROI
		cm.nROIchans(k) = length(cm.ROI2chans{k});
	end

	cm.chansbyROI = horzcat(cm.ROI2chans{:});

	EEG.SUMA = cm;

	fname = fullfile(filepath,[filename '.mat']);
	fprintf('Saving SUMA channel map with EEG data ''%s'' ... ',fname);
	save(fname,'-v7.3','EEG');
	fprintf('done\n\n');

end
