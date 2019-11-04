%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save EEG datasets in standard MATLAB .mat format without preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify ECoG data set (BP, subject), e.g.
%{
BP = false; subject = 'AnRa';
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('omax','var'), omax = 1800000; end % maximum observations per file (1800000 = 1 hour @ 500Hz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filepath = CIFAR_filename(BP,subject);

[status,msg] = mkdir(filepath,'nopreproc');
assert(status == 1,msg);

s = dir([filepath filesep '*.set']);

for i = 1:length(s)
	sname = s(i).name;
	m = strfind(sname,'_');
	j = strfind(sname,'_');
	if isempty(j), continue; end
	j = j(1);
	k = strfind(sname,'.set');
	if isempty(k), continue; end
	k = k(1);
	name = sname(j+1:k-1);
	try % catch out-of-memory errors, etc.
		[EEG,filename,filepath] = load_EEG(BP,subject,name);
	catch problem
		fprintf(2,'\n*** DATASET LOAD FAILED: %s ***\n\n',problem.identifier);
		continue
	end
	X   = double(EEG.data);
	fs  = double(EEG.srate);
	ts  = double(EEG.times); % timestamp (milliseconds)
	ev  = EEG.event;
	clear EEG

	[nchans nobs] = size(X);
	assert(nobs == length(ts),'Time stamps don''t match data!');

	froot = fullfile(filepath,'nopreproc',filename);
	if nobs <= omax
		fname = [froot '.mat'];
		fprintf('\nSaving unpreprocessed data in ''%s'' ... ',fname);
%		save(fname,'X','fs','ts','ev');
		fprintf('done\n');
	else
		Xx = X;
		tsx = ts;
		nfiles = ceil(nobs/omax);
		fprintf('\nSaving unpreprocessed data in ''%s_''\n',froot);
		for f = 1:nfiles
			o = (f-1)*omax+1;
			olen = min(omax,nobs-(f-1)*omax-1);
			oseg = o:(o+olen);
			X = Xx(:,oseg);
			ts = tsx(oseg);
			tsec1 = round(ts(1)/1000);
			tsec2 = round(ts(end)/1000);
			ftag = sprintf('seg%02d_t%05d-%05d',f,tsec1,tsec2);
			fname = sprintf('%s_%s.mat',ftag);
			fprintf('\t''%s'' ... ',ftag);
%			save(fname,'X','fs','ts','ev');
			fprintf('done\n');
		end
	end
end
