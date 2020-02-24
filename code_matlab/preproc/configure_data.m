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

sumap = get_SUMA_map(subject);

filepath = CIFAR_filename(BP,subject);

subject_dir = dir([filepath filesep '*.set']);

for i = 1:length(subject_dir)
	subject_dataset = subject_dir(i).name;
    isleeping=strfind(subject_dataset,'sleep')
    if isempty(isleeping)==0 
        continue
    end
	m = strfind(subject_dataset,'_');
	j = strfind(subject_dataset,'_');
	if isempty(j), continue; end
	j = j(1);
	k = strfind(subject_dataset,'.set');
	if isempty(k), continue; end
	k = k(1);
	dataset = subject_dataset(j+1:k-1);
	try % catch out-of-memory errors, etc.
		[filepath,filename] = CIFAR_filename(BP,subject,dataset);
		EEG = pop_loadset('filename',[filename '.set'],'filepath',filepath);
	catch problem
		fprintf(2,'\n*** DATASET LOAD FAILED (%s) ***\n\n',problem.identifier);
		continue
	end

	% Save actual time-series data in 'nopreproc' subdirectory

	tseries  = double(EEG.data);
	tstep = double(EEG.times)/1000; % seconds!

	[status,msg] = mkdir(filepath,'nopreproc');
	assert(status == 1,msg);
	fname = fullfile(filepath,'nopreproc',[filename '.mat']);
	fprintf('\nSaving unpreprocessed time-series data in ''%s'' ... ',fname);
	save(fname,'-v7.3','tseries','tstep');
	fprintf('done\n');

	EEG = rmfield(EEG,{'data','times'}); % don't need these in here anymore

	% Build SUMA channel mapping

	chan_map.channames    = cell(1,EEG.nbchan);
	chan_map.chan2elec    = zeros(1,EEG.nbchan);
	chan_map.ROInames     = unique(sumap.aparcaseg.bestLabel.labels);
	chan_map.nROIs        = length(chan_map.ROInames)+1;
	chan_map.ROInames{chan_map.nROIs} = 'unknown';
	chan_map.chan2ROI     = zeros(1,chan_map.nROIs);
	chan_map.chan2ROIname = cell(1,EEG.nbchan);
	for i = 1:EEG.nbchan
		chan_map.channames{i} = EEG.chanlocs(i).labels;
		for j = 1:sumap.nElec
			if strcmp(chan_map.channames{i},sumap.elecNames{j});
				chan_map.chan2elec(i) = j;
				chan_map.chan2ROIname{i} = sumap.aparcaseg.bestLabel.labels{j};
				continue
			end
		end
		% if still zero, it wasn't found
		if chan_map.chan2elec(i) == 0
			chan_map.chan2ROI(i)     = chan_map.nROIs;              % last ROI is 'unknown'
			chan_map.chan2ROIname{i} = chan_map.ROInames{chan_map.nROIs}; %  'unknown'
		else
			for k = 1:chan_map.nROIs % for each ROI
				if strcmp(chan_map.chan2ROIname{i},chan_map.ROInames{k})
					chan_map.chan2ROI(i) = k;
					continue;
				end
			end
		end
	end

	chan_map.ROI2chans = cell(chan_map.nROIs,1);
	chan_map.nROIchans = zeros(1,chan_map.nROIs,1);
	for k = 1:chan_map.nROIs % for each ROI
		chan_map.ROI2chans{k} = find(chan_map.chan2ROI == k); % channels matching ROI
		chan_map.nROIchans(k) = length(chan_map.ROI2chans{k});
	end

	chan_map.chansbyROI = horzcat(chan_map.ROI2chans{:});

	EEG.SUMA = chan_map;

	fname = fullfile(filepath,[filename '.mat']);
	fprintf('Saving SUMA channel map with EEG data ''%s'' ... ',fname);
	save(fname,'-v7.3','EEG');
	fprintf('done\n\n');

end
