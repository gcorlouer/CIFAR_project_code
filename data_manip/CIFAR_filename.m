function [filepath,filename] = CIFAR_filename(BP,subject,dataset)

global cfsubdir

assert(nargin > 1,'Need dataset type and subject');

if BP
	ddir = 'bipolar_montage';
else
	ddir = 'raw_signal';
end

filepath = fullfile(cfsubdir,subject,'EEGLAB_datasets',ddir);

if nargout > 1
	assert(nargin > 2,'Need dataset name');
	filename = [subject '_' dataset];
	if BP
		filename = filename;
	end
end
