%% Plot brain and electrodes script
%% Initial parameters
close all

% Create S_brain structure containing ploting info
S_brain = struct;
S_brain.plotsurf      = 'pial';    % either pial/inflated cortical surface
S_brain.ecog_map_root = ecog_map_root;
S_brain.layout        = 'compact'; % either compact/full (different layouts for examples)
S_brain.surfacealpha  = 1;         % alpha value for surface transperancy
S_brain.meshdir       = cfsubdir ;
S_brain.ch_list       = array2table(nan(1,9),'VariableNames',{'subjid','ch_label','ch_sig','ch_hemi','ch_eCrd','ch_nodeIDX','ch_handle','dist_to_srf','aparcTag'});
S_brain.ch_list(1,:)  = [];
subjid_brain          = 'AnRa';    % alternative - use an average template: 'FsAv'
subjid                = 'AnRa';    % subject electrodes  

%% Plot brain

[S_brain,H,SUMAsrf]   = plot_FS_brain_master(subjid_brain,S_brain); 

%% PLOT electrodes

% Load relevant electrodes info
sub_elocDir = fullfile(S_brain.meshdir,subjid,'brain');
load(fullfile(sub_elocDir,'SUMAprojectedElectrodes.mat'))
ch_labels   = [SUMAprojectedElectrodes.elecNames];

% Was there in the original code but does not run : ePlot=stats_table.Properties.RowNames(ismember(stats_table.Channel,visual_responsive_ROI))
ePlot    = ch_labels;
ePlot1   = ch_labels(multiStrFind(ch_labels,'Grid')|multiStrFind(ch_labels,'Grd'));
ePlot2   = setdiff(ch_labels,ePlot1); 
eSize    = 2; % radius in mm
eColor1  = [0 0 0];
eColor2  = [1 0 0];
textFlag = 1;

S_brain = plot_Fs_electrode_master(subjid,H,S_brain,SUMAsrf,sub_elocDir,ePlot1,eSize,eColor1,textFlag,'gouraud','top');
S_brain = plot_Fs_electrode_master(subjid,H,S_brain,SUMAsrf,sub_elocDir,ePlot2,eSize,eColor1,textFlag,'gouraud','top'); 
S_brain = plot_Fs_electrode_master(subjid,H,S_brain,SUMAsrf,sub_elocDir,{'Grid16'},2.5,eColor2,textFlag,'gouraud','top');

%% Save figure: 
