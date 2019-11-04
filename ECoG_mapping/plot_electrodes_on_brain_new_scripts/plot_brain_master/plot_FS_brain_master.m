% The function draws a FreeSurfer brain according to the parameters
% in the structure "S_brain".
% subjid = the patient's subjid
%
% "S_brain" should have the following fields:
%
% S_brain=struct;
% S_brain.plotsurf='pial';          % either pial/inflated cortical surface
% S_brain.layout='compact';         % either compact/full (different layouts for examples)
% S_brain.surfacealpha=1;           % alpha value for surface transperancy
% S_brain.meshdir='D:\FreeSurfer\Data\SUMA_meshData\';    % input folder where the brain and electrode structures are stored
% S_brain.ch_list= array2table(nan(1,8),'VariableNames',{'subjid','ch_label','ch_hemi','ch_eCrd','ch_nodeIDX','ch_handle','dist_to_srf','aparcTag'});
% S_brain.ch_list(1,:)= [];
%
% Author: Itzik Norman, 2019 @ Malach Lab (Weizmann Institute of Science)


function [S_brain,H,SUMAsrf] = plot_FS_brain_master(subjid,S_brain)

if isempty(subjid); subjid = 'fsaverage'; end
if ~isfield(S_brain,'layout'); S_brain.layout = 'full'; end
if ~isfield(S_brain,'plotsurf'); S_brain.plotsurf = 'inflated'; end
if ~isfield(S_brain,'surfacealpha'); S_brain.surfacealpha=1; end
if ~isfield(S_brain,'meshdir'); S_brain.meshdir='D:\ECoG\Free_Recall_RAWDATA\SUMA_meshData\'; end

meshDir=fullfile(S_brain.meshdir,subjid);
switch S_brain.plotsurf
    case 'inflated'
        load(fullfile(meshDir,'SUMAInflatedSrf.mat'))
        SUMAsrf=SUMAInflatedSrf;
        flag3d=1;
    case 'pial'
        load(fullfile(meshDir,'SUMAPialSrf.mat'))
        SUMAsrf=SUMAPialSrf;
        flag3d=1;
    case 'flat'
        load(fullfile(meshDir,'SUMACortexPatchFlat.mat'))
        SUMAsrf=SUMACortexPatchFlat;
        flag3d=0;
    otherwise
        error('Wrong plotsurf, please choose either inflated/pial/flat');
end

% load a "default" brain only to initialize face colors. You can choose
% either SUMA_default/SUMA_pial_blank/SUMA_DKatlas - for different overlaid
% colors. Default shows only the curvature in gray (look  nice on the
% inflated brain).
if ismember(S_brain.plotsurf,{'flat', 'inflated'})
    load(fullfile(S_brain.meshdir,'painted_surfaces','SUMA_ROI_DKTatlas.mat'))
    %     load(fullfile(meshDir,'painted_surfaces','SUMA_ROI_eva_intermediate_fusiform.mat'));
    
else
    load(fullfile(S_brain.meshdir,'painted_surfaces','SUMA_DKatlas.mat'));
    %load(fullfile(S_brain.meshdir,'painted_surfaces','SUMA_blank.mat'));
    %load(fullfile(meshDir,'painted_surfaces','SUMA_DKatlas.mat'));
end

% PLOT BRAIN:
FV.lh.faces = SUMAsrf(1).faces; % LH = Left Hemisphere
FV.lh.vertices = SUMAsrf(1).vertices.afniXYZ; % LH

FV.rh.faces = SUMAsrf(2).faces; % RH = Right Hemisphere
FV.rh.vertices = SUMAsrf(2).vertices.afniXYZ; % RH

% Use 3d smoothing when drawing the pial surface:
if strcmpi(S_brain.plotsurf,'pial')
    mex 'D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts\General Functions\smoothpatch\smoothpatch_curvature_double.c' -v
    mex 'D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts\General Functions\smoothpatch\smoothpatch_inversedistance_double.c' -v
    mex 'D:\ECoG\MATLAB scripts\Free_Recall_Analysis_Scripts\General Functions\smoothpatch\vertex_neighbours_double.c' -v
    FV.lh=smoothpatch(FV.lh,0,5);  % smooth the 3D surface
    FV.rh=smoothpatch(FV.rh,0,5);  % smooth the 3D surface
end

if strcmpi(S_brain.layout,'full')
    
    if flag3d
        
        H=figure('Name',['FS brain'],'units','normalized','outerposition',[0 0 1 1],'Color','w');
        hold on;
        subplot(4,2,1); hold on; axis equal
        patch('Vertices',FV.lh.vertices,'Faces',FV.lh.faces,'FaceVertexCData',cdata.lh,'FaceAlpha',S_brain.surfacealpha);
        view(-75,-10);
        lights_on;
        text(0.1,0,'LH','Color','k','fontsize',20,'FontName','timesnewroman','units','normalized');
        set(gca,'Tag','LH');
        
        subplot(4,2,3); hold on; axis equal
        patch('Vertices',FV.lh.vertices,'Faces',FV.lh.faces,'FaceVertexCData',cdata.lh,'FaceAlpha',S_brain.surfacealpha);
        view(75,-10);
        lights_on;
        set(gca,'Tag','LH');
        
        subplot(4,2,[6 8]); hold on; axis equal
        patch('Vertices',FV.lh.vertices,'Faces',FV.lh.faces,'FaceVertexCData',cdata.lh,'FaceAlpha',S_brain.surfacealpha);
        view(0,260); axis tight; %xlim([-150 50]);
        lights_on;
        text(0.45,0.02,'LH','Color','k','fontsize',16,'FontName','timesnewroman','units','normalized');
        set(gca,'Tag','LH');
        
        subplot(4,2,2); hold on; axis equal
        patch('Vertices',FV.rh.vertices,'Faces',FV.rh.faces,'FaceVertexCData',cdata.rh,'FaceAlpha',S_brain.surfacealpha);
        view(75,-10);
        lights_on;
        text(0.9,0,'RH','Color','k','fontsize',20,'FontName','timesnewroman','units','normalized');
        set(gca,'Tag','RH');
        
        subplot(4,2,4); hold on; axis equal
        patch('Vertices',FV.rh.vertices,'Faces',FV.rh.faces,'FaceVertexCData',cdata.rh,'FaceAlpha',S_brain.surfacealpha);
        view(-75,-10);
        lights_on;
        set(gca,'Tag','RH');
        
        subplot(4,2,[5 7]); hold on; axis equal
        patch('Vertices',FV.rh.vertices,'Faces',FV.rh.faces,'FaceVertexCData',cdata.rh,'FaceAlpha',S_brain.surfacealpha);
        view(0,260); axis tight %xlim([-150 50]);
        lights_on;
        text(0.5,0.02,'RH','Color','k','fontsize',16,'FontName','timesnewroman','units','normalized');
        set(gca,'Tag','RH');
        
        
    else % (for a flatten 2d surface)
        H=figure('Name',['FS brain'],'units','normalized','outerposition',[0 0 1 1],'Color','w');
        hold on;
        subplot(1,2,1); hold on;
        pos=get(gca,'position');
        set(gca,'position',[pos(1)-(0.1*pos(3)) pos(2)-(0.1*pos(4)) pos(3)*1.2 pos(4)*1.2],'units','normalized');
        patch('Vertices',FV.lh.vertices,'Faces',FV.lh.faces,'FaceVertexCData',cdata.lh,'FaceAlpha',S_brain.surfacealpha);
        shading flat; freezeColors; axis off; colormap gray;
        set(gca,'Tag','LH');
        text(0.1,0.95,'LH','Color','k','fontsize',20,'FontName','timesnewroman','units','normalized');
        view(90,90); axis tight; axis equal;
        set(gca,'YLimMode','manual','ZLimMode','manual')
        
        subplot(1,2,2); hold on;
        pos=get(gca,'position');
        set(gca,'position',[pos(1)-(0.1*pos(3)) pos(2)-(0.1*pos(4)) pos(3)*1.2 pos(4)*1.2],'units','normalized');
        patch('Vertices',FV.rh.vertices,'Faces',FV.rh.faces,'FaceVertexCData',cdata.rh,'FaceAlpha',S_brain.surfacealpha);
        shading flat; freezeColors; axis off; colormap gray;
        set(gca,'Tag','RH');
        text(0.9,0.95,'RH','Color','k','fontsize',20,'FontName','timesnewroman','units','normalized');
        view(90,90); axis tight; axis equal;
        set(gca,'YLimMode','manual','ZLimMode','manual')
    end
    
elseif strcmpi(S_brain.layout,'compact')
    
    if flag3d
        H=figure('Name',['FS brain'],'units','normalized','outerposition',[0 0.1 1 0.5],'Color','w');
        hold on;
        
        subplot(1,4,1); hold on; axis equal
        patch('Vertices',FV.lh.vertices,'Faces',FV.lh.faces,'FaceVertexCData',cdata.lh,'FaceAlpha',S_brain.surfacealpha);
        switch S_brain.plotsurf
            case 'inflated', view(-60,6);
            case 'pial', view([-80 0]);
        end
        lights_on;
        set(gca,'Tag','LH');
        axis equal tight; %xlim([-90 0]);
        
        subplot(1,4,3); hold on; axis equal
        patch('Vertices',FV.lh.vertices,'Faces',FV.lh.faces,'FaceVertexCData',cdata.lh,'FaceAlpha',S_brain.surfacealpha);
        %view(0,268);
        view(-90.1,-88);
        lights_on;
        set(gca,'Tag','LH');
        axis equal tight;
        
        subplot(1,4,2); hold on; axis equal
        patch('Vertices',FV.rh.vertices,'Faces',FV.rh.faces,'FaceVertexCData',cdata.rh,'FaceAlpha',S_brain.surfacealpha);
        %view(0,268);
        view(-90.1,-89.5);
        lights_on;
        set(gca,'Tag','RH');
        axis equal tight; %xlim([0 90]);
        
        
        subplot(1,4,4); hold on; axis equal
        patch('Vertices',FV.rh.vertices,'Faces',FV.rh.faces,'FaceVertexCData',cdata.rh,'FaceAlpha',S_brain.surfacealpha);
        switch S_brain.plotsurf
            case 'inflated', view(60,6);
            case 'pial', view([80 0]);
        end
        lights_on;
        set(gca,'Tag','RH');
        axis equal tight; %xlim([0 90]);
        
        
    else
        H=figure('Name',['FS brain'],'units','normalized','outerposition',[0.1 0.1 0.9 0.9],'Color','w');
        hold on;
        pos=get(gca,'position');
        set(gca,'position',[pos(1)+0.3*pos(3) pos(2) pos(3) pos(4)])
        subplot(1,2,1); hold on;
        patch('Vertices',FV.lh.vertices,'Faces',FV.lh.faces,'FaceVertexCData',cdata.lh,'FaceAlpha',S_brain.surfacealpha);
        shading flat; axis vis3d; freezeColors;
        axis off; colormap gray; axis tight; axis equal;
        set(gca,'Tag','LH');
        text(0.1,0.95,'LH','Color','k','fontsize',20,'FontName','timesnewroman','units','normalized');
        view(90,90); ylim([-250 50]);
        set(gca,'YLimMode','manual','ZLimMode','manual')
        
        subplot(1,2,2); hold on;
        pos=get(gca,'position');
        set(gca,'position',[pos(1)-0.3*pos(3) pos(2) pos(3) pos(4)])
        patch('Vertices',FV.rh.vertices,'Faces',FV.rh.faces,'FaceVertexCData',cdata.rh,'FaceAlpha',S_brain.surfacealpha);
        shading flat; axis vis3d; freezeColors;
        axis off; colormap gray; axis tight; axis equal;
        set(gca,'Tag','RH');
        text(0.78,0.95,'RH','Color','k','fontsize',20,'FontName','timesnewroman','units','normalized');
        view(90,90);  ylim([-50 250]);
        set(gca,'YLimMode','manual','ZLimMode','manual')
    end
    
end
end

function lights_on
delete(findall(gca,'type','light'));
v = get(gca,'view');
c(1) = camlight('headlight');
axis off; colormap gray; rotate3d; axis tight; axis vis3d;
freezeColors;
material dull
shading interp
set(gca,'CameraPositionMode','manual');
set(findall(gca,'type','patch'),'AmbientStrength',0.25) 
set(findall(gca,'type','patch'),'AmbientStrength',0.3)
set(findall(gca,'type','patch'),'FaceLighting','gouraud')
end


