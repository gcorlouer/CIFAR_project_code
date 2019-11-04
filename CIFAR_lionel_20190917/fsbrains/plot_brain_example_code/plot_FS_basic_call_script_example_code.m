
% Supply 'subject'; e.g.,
%
% subject = 'AnRa'; plot_FS_basic_call_script_example_code

% Directories:

global cfdatadir % CIFAR base data directory

datadir  = fullfile(cfdatadir,'iEEG_10');
subdir   = fullfile(datadir,'subjects',subject);
braindir = fullfile(subdir,'Brain');
figdir   = fullfile(subdir,'figs');

%addpath('D:\Itzik_DATA\MATLAB ToolBoxes\eeglab14_1_2b');
%addpath(genpath('D:\plot_brain'));

%% PLOT FS barin:
% close all

S_brain=struct;
S_brain.plotsurf='pial';
S_brain.layout='compact';
S_brain.surfacealpha=1;
S_brain.meshdir=braindir;
S_brain.ch_list= array2table(nan(1,9),'VariableNames',{'subjid','ch_label','ch_sig','ch_hemi','ch_eCrd','ch_nodeIDX','ch_handle','dist_to_srf','aparcTag'});
S_brain.ch_list(1,:)= [];
disp_brain=subject; % alternative - use an average template: 'fsaverage'
[S_brain,H,SUMAsrf] = plot_FS_brain_example_code(disp_brain,S_brain);


%% PLOT electrodes
initials=subject;
elocDir=braindir;
load(fullfile(elocDir,'SUMAprojectedElectrodes.mat'))
     ch_labels=[SUMAprojectedElectrodes.elecNames];
%    ePlot=stats_table.Properties.RowNames(ismember(stats_table.Channel,visual_responsive_ROI));
     ePlot=ch_labels;
     ePlot1=ch_labels(multiStrFind(ch_labels,'Grid')|multiStrFind(ch_labels,'Grd'));
     ePlot2=setdiff(ch_labels,ePlot1);
     eSize=2; % radius in mm
     eColor1=[0 0 0];
     eColor2=[1 0 0];
     textFlag=1;

     S_brain=plot_Fs_electrode_example_code(initials,H,S_brain,SUMAsrf,elocDir,ePlot1,eColor1,eSize,textFlag,'gouraud','top');
     S_brain=plot_Fs_electrode_example_code(initials,H,S_brain,SUMAsrf,elocDir,ePlot2,eColor1,eSize,textFlag,'gouraud','top');
     S_brain=plot_Fs_electrode_example_code(initials,H,S_brain,SUMAsrf,elocDir,{'Grid16'},eColor2,2.5,textFlag,'gouraud','top');
  %% Save figure:

     figname=[initials '_on_blank_surface'];
     outdir=figdir;
     if ~exist(outdir,'dir')
         mkdir(outdir);
         disp('Creating Output Directory...')
     end
     %saveas(gcf,fullfile(outdir,[figname '.fig']))
     export_fig(fullfile(outdir,figname),'-jpg','-r100')
