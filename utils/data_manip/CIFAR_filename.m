%% Select filename 
%% Parameters
% BP= true or false; bipolar montage or raw
% subject: subject name
% preproc: preproc or noprproc data
% task : 'rest_baseline_1', 'rest_baseline_1','sleep', 'stimuli_1', 'stimuli_2';
%% 
function [fname, fpath, dataset] = CIFAR_filename(varargin)

defaultBP = true;
defaultSubject = 'AnRa';
defaultTask = 'rest_baseline_1';
defaultExt = '.set';
defaultPreproc = 'nopreproc';

p = inputParser;

addParameter(p, 'BP', defaultBP, @islogical);
addParameter(p, 'subject', defaultSubject, @isvector);
addParameter(p, 'task', defaultTask,@isvector);
addParameter(p, 'ext', defaultExt,@isvector);
addParameter(p, 'preproc', defaultPreproc,@isvector);

parse(p, varargin{:});

global cfsubdir

if p.Results.BP
	ddir = fullfile('bipolar_montage', p.Results.preproc);
else
	ddir = fullfile('raw_signal', p.Results.preproc);
end

fpath = fullfile(cfsubdir,p.Results.subject,'EEGLAB_datasets',ddir);

if p.Results.BP
    dataset = [p.Results.subject '_' 'freerecall_' p.Results.task '_preprocessed_BP_montage'];
else
    dataset = [p.Results.subject '_' 'freerecall_' p.Results.task '_preprocessed'];
end

fname = [dataset p.Results.ext];

end
