% Startup stuff

global CIFAR_version;
CIFAR_version.major = 1;
CIFAR_version.minor = 0;

%fprintf('[CIFAR startup] Initialising CIFAR version %d.%d\n', PsyMEG_version.major, PsyMEG_version.minor);

% Add CIFAR root dir + appropriate subdirs to path

global CIFAR_root;
CIFAR_root = fileparts(mfilename('fullpath')); % directory containing this file
addpath(CIFAR_root);
addpath(fullfile(CIFAR_root,'utils'));
addpath(genpath(fullfile(CIFAR_root,'analysis')));
addpath(fullfile(CIFAR_root,'tests'));
addpath(fullfile(CIFAR_root,'data'));
addpath(fullfile(CIFAR_root,'deprecated'));
addpath(fullfile(CIFAR_root,'preproc'));
addpath(fullfile(CIFAR_root,'HFB_envelope'));
addpath(genpath(fullfile(CIFAR_root,'fsbrains')));
fprintf('[CIFAR startup] Added path %s and appropriate subpaths\n',CIFAR_root);

% Initialize mvgc library

global mvgc_root;
mvgc_root = fullfile(fileparts(CIFAR_root),'code_matlab','mvgc'); % i.e. same directory level as CIFAR !!! AMEND IF NECESSARY !!!
assert(exist(mvgc_root,'dir') == 7,'bad MVGC path: ''%s'' does not exist or is not a directory',mvgc_root);
cd(mvgc_root);
startup;
cd(CIFAR_root);

% Initialize EegLab

global eeglab_root;
eeglab_root = fullfile(getenv('MATLAB_EEGLAB'));
addpath(eeglab_root);
addpath(genpath(fullfile(eeglab_root,'functions')));

% Amend for your CIFAR data set-up

global datadir cfdatadir cffigdir cfsubdir cfmetadata
datadir    = getenv('DATADIR');
cfdatadir  = fullfile(datadir,'CIFAR_data');
cffigdir   = fullfile(cfdatadir,'iEEG_10','figures');
cfsubdir   = fullfile(cfdatadir,'iEEG_10','subjects');
cfmetadata = fullfile(cfdatadir,'metadata','metadata.mat');

% Image viewers

global rasviewer pdfviewer svgviewer
rasviewer = 'feh';
pdfviewer = 'mupdf';
svgviewer = 'inkview';

% Get screen size

global screenxy

s = get(0,'ScreenSize');
screenxy = s([3 4]);

% Make all plot fonts bigger!

set(0,'DefaultAxesFontSize',12);
set(0,'DefaultTextFontSize',12);

% Make plot colours sane (like the old MATLAB)!

set(groot,'defaultAxesColorOrder',[0 0 1; 0 0.5 0; 1 0 0; 0 0.75 0.75; 0.75 0 0.75; 0.75 0.75 0; 0.25 0.25 0.25]);

fprintf('[CIFAR startup] Initialised (you may re-run `startup'' at any time)\n');
