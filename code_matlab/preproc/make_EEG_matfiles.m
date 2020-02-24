%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make matfiles containing everything except the time series data!
% Save the actual data in a 'nopreproc' subdirectory.
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
		[filepath,filename] = CIFAR_filename(BP,subject,dataset);
		EEG = pop_loadset('filename',[filename '.set'],'filepath',filepath);
	catch problem
		fprintf(2,'\n*** DATASET LOAD FAILED (%s) ***\n\n',problem.identifier);
		continue
	end

	X  = double(EEG.data);
	ts = double(EEG.times)/1000; % seconds!

	[status,msg] = mkdir(filepath,'nopreproc');
	assert(status == 1,msg);
	fname = fullfile(filepath,'nopreproc',[filename '.mat']);
	fprintf('\nSaving unpreprocessed time-series data in ''%s'' ... ',fname);
	save(fname,'-v7.3','X','ts');
	fprintf('done\n');

	EEG = rmfield(EEG,{'data','times'});

	fname = fullfile(filepath,[filename '.mat']);
	fprintf('Saving other EEG in ''%s'' ... ',fname);
	save(fname,'-v7.3','EEG');
	fprintf('done\n\n');
end
