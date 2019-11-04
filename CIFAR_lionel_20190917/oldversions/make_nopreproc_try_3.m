%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save EEG datasets in standard MATLAB .mat format without preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify ECoG data set (BP, subject), e.g.
%{
BP = false; subject = 'AnRa';
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filepath = CIFAR_filename(BP,subject);

[status,msg] = mkdir(filepath,'nopreproc');
assert(status == 1,msg);

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
		[EEG,filename,filepath] = load_EEG(BP,subject,dataset);
	catch problem
		fprintf(2,'\n*** DATASET LOAD FAILED (%s) ***\n\n',problem.identifier);
		continue
	end
	X  = double(EEG.data);
	ts = double(EEG.times)/1000; % seconds!
	fs = double(EEG.srate);
	ev = EEG.event;
	clear EEG

	fname = fullfile(filepath,'nopreproc',[filename '.mat']);
	fprintf('\nSaving unpreprocessed data in ''%s'' ... ',fname);
	save(fname,'-v7.3','X','ts','fs','ev');
	fprintf('done\n');
end
