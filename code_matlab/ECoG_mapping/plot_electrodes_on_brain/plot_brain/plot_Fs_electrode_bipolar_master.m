% Plot a single electrode:

function S = plot_Fs_electrode_bipolar_master(initials,H,S,SUMAsrf,elocDir,ch_labels,eColor,eSize,textFlag,shading,order)
%================================
checkSurfDist=0;
%===============================
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


chk = all(multiStrFind(ch_labels,'-'));
if chk, disp('Bipolar montage detected - presenting pairs of electrodes...');
else disp(' *** Electrode labels format is not uniform - at least one channel is not biploar ***'); return;
end

if ~exist(fullfile(elocDir,'SUMAprojectedElectrodes.mat'),'file')
    warning('Elecrodes location file does not exist');
else
    load(fullfile(elocDir,'SUMAprojectedElectrodes.mat'));
    fprintf('\n Loading Elecrodes location file: %s \n',elocDir);
end

set(0, 'CurrentFigure', H); hold on;
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
    
    current_label = ch_labels(i);
    [ch1.label,tmp] = strtok(current_label,'-');
    [ch2.label] = strtok(tmp,'-');
    ch1.label = cell2mat(ch1.label);
    ch2.label = cell2mat(ch2.label);
    ch1.idx=find(strcmpi(SUMAprojectedElectrodes.elecNames,ch1.label));
    ch2.idx=find(strcmpi(SUMAprojectedElectrodes.elecNames,ch2.label));
    % =====================================================================
    fprintf('\n %s - index: %d \n %s - index: %d \n',ch1.label,ch1.idx,ch2.label,ch2.idx);
    if isempty(ch1.idx);
        warning('*** Cannot find electrode %s ***',ch1.label);  beep;
        continue;
    end
    
    if isempty(ch2.idx);
        warning(sprintf('*** Cannot find electrode %s ***',ch2.label));  beep;
        continue;
    end
    % =====================================================================
    if strcmpi(SUMAprojectedElectrodes.hemisphere(ch1.idx),'lh'), ch1.hemi=1;
        axesHandle1=unique(findobj(gcf,'Tag','LH'));
    elseif strcmpi(SUMAprojectedElectrodes.hemisphere(ch1.idx),'rh'), ch1.hemi=2;
        axesHandle1=unique(findobj(gcf,'Tag','RH'));
    else warning(sprintf('%s - hemisphere data is missing! please check \n',ch1.label));
    end
    
    if strcmpi(SUMAprojectedElectrodes.hemisphere(ch2.idx),'lh'), ch2.hemi=1;
        axesHandle2=unique(findobj(gcf,'Tag','LH'));
    elseif strcmpi(SUMAprojectedElectrodes.hemisphere(ch2.idx),'rh'), ch2.hemi=2;
        axesHandle2=unique(findobj(gcf,'Tag','RH'));
    else warning(sprintf('%s - hemisphere data is missing! please check \n',ch2.label));
    end
    % =====================================================================
    ch1.nodeIDX=SUMAprojectedElectrodes.nodeInd(ch1.idx);
    ch2.nodeIDX=SUMAprojectedElectrodes.nodeInd(ch2.idx);
    ch1.eCrd=SUMAsrf(ch1.hemi).vertices.afniXYZ(ch1.nodeIDX,:);
    ch2.eCrd=SUMAsrf(ch1.hemi).vertices.afniXYZ(ch2.nodeIDX,:);
    % =====================================================================
    % Alternatives:
    ch1.aparcTag=SUMAprojectedElectrodes.aparcaseg.bestLabel.labels(ch1.idx);
    ch2.aparcTag=SUMAprojectedElectrodes.aparcaseg.bestLabel.labels(ch2.idx);
    ch1.dist2srf=SUMAprojectedElectrodes.distanceInMMToMesh(ch1.idx);
    ch2.dist2srf=SUMAprojectedElectrodes.distanceInMMToMesh(ch2.idx);
    % =====================================================================
    
    if ch1.dist2srf > 5 && checkSurfDist % skip channels that are not on the surface
        warning('\n *** Electrode %s is to far from the surface *** \n',ch1.label);
        continue;
    end
    if ch2.dist2srf > 5 && checkSurfDist % skip channels that are not on the surface
        warning('\n *** Electrode %s is to far from the surface *** \n',ch2.label);
        continue;
    end
    
    if axesHandle1~=axesHandle2
        error('\n *** Bipole %s and %s is not on the same hemisphere, please check *** \n',ch1.label,ch2.label);
    else
        axesHandle = axesHandle1;
    end
    % =====================================================================
    w = 1; % linewidth
    BTF = 0.001; % bring to front
    pullingExtent = 5;
    for h=axesHandle'
        
        % Plot 2d circles when using flat brain:
        if strcmpi(S.plotsurf,'flat')
            %hp = plot3(xyz(:,1),xyz(:,2),xyz(:,3),'-','linewidth',w,'color',color); uistack(hp,order);
            ch1.handle=scatter3(h,ch1.eCrd(1),ch1.eCrd(2),ch1.eCrd(3)+BTF,s^2,'o','Markerfacecolor',color,'Markeredgecolor','k','LineWidth',0.5); %0.5
            ch2.handle=scatter3(h,ch2.eCrd(1),ch2.eCrd(2),ch2.eCrd(3)+BTF,s^2,'o','Markerfacecolor',color,'Markeredgecolor','k','LineWidth',0.5);
            
        else
            
%             pulledCrd1=pullElectrodesTowardsTheCamera(ch1.eCrd,h,pullingExtent);
%             pulledCrd2=pullElectrodesTowardsTheCamera(ch2.eCrd,h,pullingExtent);
%             ch1.handle=scatter3(h,pulledCrd1(1),pulledCrd1(2),pulledCrd1(3),s^2,'o','Markerfacecolor',color,'Markeredgecolor','k','LineWidth',0.5);  %
%             ch2.handle=scatter3(h,pulledCrd2(1),pulledCrd2(2),pulledCrd2(3),s^2,'o','Markerfacecolor',color,'Markeredgecolor','k','LineWidth',0.5); % 
            
            % for adding a line:
            % hp = plot3(xyz(:,1),xyz(:,2),xyz(:,3),'--','linewidth',w,'color',color); uistack(hp,order);
            % for 3d spheres:
            ch1.handle=surf(h,double(xx+ch1.eCrd(1)'),double(yy+ch1.eCrd(2)'),double(zz+ch1.eCrd(3)'),'facecolor',color,'edgecolor','none','FaceLighting',shading,'SpecularStrength',0.2); %,'edgeLighting','flat'
            ch2.handle=surf(h,double(xx+ch2.eCrd(1)'),double(yy+ch2.eCrd(2)'),double(zz+ch2.eCrd(3)'),'facecolor',color,'edgecolor','none','FaceLighting',shading,'SpecularStrength',0.2); %,'edgeLighting','flat'
        end
        
        if textFlag
            set(ch1.handle,'buttondownfcn',sprintf('disp(''%s_%s'')',initials,cell2mat(current_label)));
            set(ch2.handle,'buttondownfcn',sprintf('disp(''%s_%s'')',initials,cell2mat(current_label)));
        end
        
    end
    uistack(ch1.handle,order)
    uistack(ch2.handle,order)
end
if isfield(ch1,'handle') && isfield(ch2,'handle')
    set(ch1.handle,'tag',[initials '_' ch1.label]);
    set(ch2.handle,'tag',[initials '_' ch2.label]);
    %         C1={initials,ch1.label,ch1.hemi,ch1.eCrd,ch1.nodeIDX,ch1.handle,ch1.dist2srf,ch1.aparcTag};
    %         C2={initials,ch2.label,ch2.hemi,ch2.eCrd,ch2.nodeIDX,ch2.handle,ch2.dist2srf,ch2.aparcTag};
    %         tmp_table1=array2table(C1,'VariableNames',S.ch_list.Properties.VariableNames);
    %         tmp_table2=array2table(C2,'VariableNames',S.ch_list.Properties.VariableNames);
    %         S.ch_list=[S.ch_list; tmp_table1; tmp_table2;];
end
end



