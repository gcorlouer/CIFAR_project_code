% Startup stuff

global CIFAR;
PsyMEG_version.major = 1;
PsyMEG_version.minor = 0;

fprintf('[CIFAR startup] Initialising CIFAR version %d.%d\n', PsyMEG_version.major, PsyMEG_version.minor);

% Add CIFAR root dir + appropriate subdirs to path

global CIFAR_root;
CIFAR_root = fileparts(mfilename('fullpath')); % directory containing this file
addpath(CIFAR_root);
addpath(fullfile(CIFAR_root,'utils'));
addpath(fullfile(CIFAR_root,'tests'));
addpath(fullfile(CIFAR_root,'metadata'));
fprintf('[CIFAR startup] Added path %s and appropriate subpaths\n',CIFAR_root);

% Initialize mvgc library

global mvgc_root;
mvgc_root = fullfile(fileparts(CIFAR_root),'/CIFAR_guillaume/mvgc_v2.0_20181120'); % i.e. same directory level as CIFAR !!! AMEND IF NECESSARY !!!
assert(exist(mvgc_root,'dir') == 7,'bad MVGC path: ''%s'' does not exist or is not a directory',mvgc_root);
cd(mvgc_root);
startup;
cd(CIFAR_root);

% Initialize EegLab

global eeglab_root;
eeglab_root = fullfile(getenv('MATLAB_EEGLAB'));
addpath(eeglab_root);
addpath(genpath(fullfile(eeglab_root,'functions')));

% Initialize Fieldtrip
%{
global fieldtrip_root;
fieldtrip_root = fullfile(getenv('MATLAB_FIELDTRIP'));
addpath(fieldtrip_root);
%}

% Initialize BrainNetViewer
%{
global BrainNetViewer_root;
BrainNetViewer_root = fullfile(getenv('MATLAB_BRAIN_NET_VIEWER'));
addpath(BrainNetViewer_root);
%}

setenv('CFDATADIR',fullfile(getenv('DATADIR'),'CIFAR'));
setenv('METADATA', fullfile(getenv('DATADIR'),'CIFAR','metadata','metadata.mat'));

fprintf('[CIFAR startup] Initialised (you may re-run `startup'' at any time)\n');
