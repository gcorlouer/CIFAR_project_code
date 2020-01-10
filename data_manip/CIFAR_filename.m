%% Select filename 
%% Parameters
% BP=0 or 1; bipolar montage or raw
% subject: subject name
% task : 'rest_baseline_1', 'rest_baseline_1','sleep', 'stimuli_1', 'stimuli_2';
%% 
function [filepath,filename] = CIFAR_filename(BP,subject,task)

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
	filename = [subject '_' 'freerecall_' task '_preprocessed'];
	if BP
		filename = [subject '_' 'freerecall_' task '_preprocessed_BP_montage'];
	end
end
