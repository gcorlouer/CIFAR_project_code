% Plot a single electrode:
function S = plot_Fs_electrode_master(subjid,H,S,SUMAsrf,elocDir,ch_labels,eColor,eSize,textFlag,shading,order)


% Set manually whether you want to use projected electrode locations:
projectedFlag = 0;


if isempty(H)||isempty(S)
    error('Missing arguments!');
end
if isempty(eSize)
    eSize=3;
    fprintf('Elecrodes size was set to default (%d mm)',eSize);
end

if isempty(order)
    order='top';
end

if isempty(eColor)
    fprintf('Elecrodes color was set to default (black)');
    eColor=[0 0 0];
end

if ~exist(fullfile(elocDir,'SUMAprojectedElectrodes.mat'),'file')
    warning('Elecrodes location file does not exist');
else
    load(fullfile(elocDir,'SUMAprojectedElectrodes.mat'));
    fprintf('\n Loading Elecrodes location file: %s \n',elocDir);
end


if projectedFlag == 0 
    if ~exist(fullfile(elocDir,'electrodes.mat'),'file')
        warning('Elecrodes location file does not exist');
    else
        load(fullfile(elocDir,'electrodes.mat'));
        fprintf('\n Loading Elecrodes location file: %s \n',elocDir);
    end    
end

%set(0, 'CurrentFigure', H);
hold on;
child_handles=findall(gcf);

ch=[];
for i=1:numel(ch_labels)
    if size(eColor,1)>1
        color=eColor(i,:);
    else
        color=eColor;
    end
    if numel(eSize)>1
        s=eSize(i);
    else
        s=eSize;
    end
    
    % Electrode in 3d Mesh:
    [xx,yy,zz]=sphere(100);
    R=s; % sphere radius
    xx=xx*R; yy=yy*R; zz=zz*R;
    
    ch.label=ch_labels{i};
    ch.idx=find(strcmpi(SUMAprojectedElectrodes.elecNames,ch.label));
    fprintf('\n %s - index: %d \n',ch.label,ch.idx);
    if isempty(ch.idx)
        warning(sprintf('*** Cannot find electrode %s ***',ch.label));
        beep;
        continue
    end
    
    if strcmpi(SUMAprojectedElectrodes.hemisphere(ch.idx),'lh')
        ch.hemi=1;
        axesHandle=unique(findobj(child_handles,'Tag','LH'));
    elseif strcmpi(SUMAprojectedElectrodes.hemisphere(ch.idx),'rh')
        ch.hemi=2;
        axesHandle=unique(findobj(child_handles,'Tag','RH'));
    else
        warning(sprintf('%s - hemisphere data is missing! please check \n',ch.label));
    end
    
    ch.nodeIDX=SUMAprojectedElectrodes.nodeInd(ch.idx);    
    if projectedFlag    
       ch.eCrd = SUMAsrf(ch.hemi).vertices.afniXYZ(ch.nodeIDX,:);
    else
       ch.eCrd = electrodes.coord.afniXYZ(ch.idx,:); 
    end
    % Alternatives:
    ch.aparcTag=SUMAprojectedElectrodes.aparcaseg.bestLabel.labels(ch.idx);
    ch.dist2srf=SUMAprojectedElectrodes.distanceInMMToMesh(ch.idx);
    pullingExtent = 5;
%     for h=axesHandle'
%         % Plot 2d circles when using flat brain:
%         if strcmpi(S.plotsurf,'flat')
%             ch.handle=scatter3(h,ch.eCrd(1),ch.eCrd(2),ch.eCrd(3)+0.001,s^2,'o','Markerfacecolor',color,'Markeredgecolor','k','LineWidth',0.5);
%         else
%             %ch.handle=surf(h,double(xx+ch.eCrd(1)'),double(yy+ch.eCrd(2)'),double(zz+ch.eCrd(3)'),'facecolor',color,'edgecolor','none','FaceLighting',shading,'SpecularStrength',0.2); %,'edgeLighting','flat'
%             % alternative: pull electrode toward the camera:
%             %pulledCrd=pullElectrodesTowardsTheCamera(ch.eCrd,h,pullingExtent);
% %             ch.handle=scatter3(h,pulledCrd(1),pulledCrd(2),pulledCrd(3),s^2,'o','Markerfacecolor',color,'Markeredgecolor','k','LineWidth',0.5);  %
%             %ch.handle=surf(h,double(xx+pulledCrd(1)'),double(yy+pulledCrd(2)'),double(zz+pulledCrd(3)'),'facecolor',color,'edgecolor','none','FaceLighting',shading,'SpecularStrength',0.2); %,'edgeLighting','flat'
%    
%         end
%         if textFlag, set(ch.handle,'buttondownfcn',sprintf('disp(''%s_%s'')',subjid,ch.label)); end
%     end
    
    if isfield(ch,'handle')
        uistack(ch.handle,order)
        set(ch.handle,'tag',[subjid '_' ch.label]);
    end
end

end

