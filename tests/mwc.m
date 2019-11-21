% This is a Matlab code (mwc.m) for calculating multiple wavelet coherence.
% Please copy the following content into a txt file and rename it to “mwc.m” prior to running.
function varargout=mwc(X,varargin)
% Multiple Wavelet coherence
% Creates a figure of multiple wavelet coherence
% USAGE: [Rsq,period,scale,coi,sig95]=mwc(X,[,settings])
%
% Input: X: a matrix of multiple variables equally distributed in space
% or time. The first column corresponds to the dependent variable,
% and the second and consequent columns are independent variables.
%
% Settings: Pad: pad the time series with zeros?
% . Dj: Octaves per scale (default: '1/12')
% . S0: Minimum scale
% . J1: Total number of scales
% . Mother: Mother wavelet (default 'morlet')
% . MaxScale: An easier way of specifying J1
% . MakeFigure: Make a figure or simply return the output.
% . BlackandWhite: Create black and white figures
% . AR1: the ar1 coefficients of the series
% .
% .
% (default='auto' using a naive ar1 estimator. See ar1nv.m)
% MonteCarloCount: Number of surrogate data sets in the significance calculation. (default=1000)
% Settings can also be specified using abbreviations. e.g. ms=MaxScale.
% For detailed help on some parameters type help wavelet.
% Example:
% t=[1:200]';
% mwc([sin(t),sin(t.*cos(t*.01)),cos(t.*sin(t*.01))])
% Please acknowledge the use of this software package in any publications,
% by including text such as:
% "The software for the multiple wavelet coherence was provided by W. Hu
% and B. Si, and is available in the Supplement of Hu and Si (2016)."
% and cite the paper:
% "Hu, W., and B. Si (2016), Technical Note: Multiple wavelet coherence for untangling scale-specific and localized
% multivariate relationships in geosciences, Hydrol. Earth Syst. Sci., volume and page numbers to be allocated."

% (C) W. Hu and B. Si 2016
%
% -----------------------------------------------------------
%
% Copyright (C) 2016, W. Hu and B. Si 2016
% This software may be used, copied, or redistributed as long as it is not
% sold and this copyright notice is reproduced on each copy made. This
% routine is provided as is without any express or implied warranties
% whatsoever.
%
%
% Wavelet software was provided by C. Torrence and G. Compo,
% %
% and is available at URL: http://paos.colorado.edu/research/wavelets/.
% %
% %
% Crosswavelet and wavelet coherence software were provided by
% %
% A. Grinsted and is available at URL:
% %
% http://www.glaciology.net/wavelet-coherence
% %
% We acknowledge Aslak Grinsted for his wavelet coherency code (wtc.m) on
% which this code builds.
%
%----------------parse function arguments-----------------------------------------------------
[row,col]=size(X);
[y,dt]=formatts(X(:,1));
mm=y(1,1);
nn=y(end,1);
for i=2:col;
[x,dtx]=formatts(X(:,i));
if (dt~=dtx)
error('timestep must be equal between time series');
end
mm1=x(1,1);
nn1=x(end,1);
if mm1>mm
mm=mm1;
end
if nn1<nn
    nn=nn1;
end
x1(:,(i-1))=x(:,1);
x2(:,(i-1))=x(:,2);
end
t=(mm:dt:nn)';
%common time period
if length(t)<4
error('The three time series must overlap.');
end
n=length(t);
%----------default arguments for the wavelet transform-----------
Args=struct('Pad',1,...
% pad the time series with zeroes (recommended)
'Dj',1/12, ... % this will do 12 sub-octaves per octave
'S0',2*dt,... % this says start at a scale of 2 years
'J1',[],...
'Mother','Morlet', ...
'MaxScale',[],... %a more simple way to specify J1
'MakeFigure',(nargout==0),...
'MonteCarloCount',1000,...
'BlackandWhite',0,...
'AR1','auto',...
'ArrowDensity',[30 30],...
'ArrowSize',1,...
'ArrowHeadSize',1);
Args=parseArgs(varargin,Args,{'BlackandWhite'});
if isempty(Args.J1)
if isempty(Args.MaxScale)
Args.MaxScale=(n*.17)*2*dt; %auto maxscale;
end
Args.J1=round(log2(Args.MaxScale/Args.S0)/Args.Dj);
end
ad=mean(Args.ArrowDensity);
Args.ArrowSize=Args.ArrowSize*30*.03/ad;
%Args.ArrowHeadSize=Args.ArrowHeadSize*Args.ArrowSize*220;
Args.ArrowHeadSize=Args.ArrowHeadSize*120/ad;
if ~strcmpi(Args.Mother,'morlet')
warning('MWC:InappropriateSmoothingOperator','Smoothing operator is designed for morlet wavelet.');
end
if strcmpi(Args.AR1,'auto')
for i=1:col
arc(i)= ar1nv(X(:,i));
end
Args.AR1=arc
if any(isnan(Args.AR1))
error('Automatic AR1 estimation failed. Specify it manually (use arcov or arburg).');
end
end
%-----------:::::::::::::--------- ANALYZE ----------::::::::::::------------
%Calculate and smooth wavelet spectrum Y and X
[Y,period,scale,coiy] = wavelet(y(:,2),dt,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother);
sinv=1./(scale');
smY=smoothwavelet(sinv(:,ones(1,n)).*(abs(Y).^2),dt,period,Args.Dj,scale);
dte=dt*.01;
idx=find((y(:,1)>=(t(1)-dte))&(y(:,1)<=(t(end)+dte)));
Y=Y(:,idx);
smY=smY(:,idx);
coiy=coiy(idx);
coi=coiy;
for i=2:col
[XS,period,scale,coix] = wavelet(x2(:,(i-1)),dt,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother);
idx=find((x1(:,(i-1))>=(t(1))-dte)&(x1(:,(i-1))<=(t(end)+dte)));
XS=XS(:,idx);
coix=coix(idx);
XS1(:,:,(i-1))=XS;
coi=min(coi,coix);
end
% -------- Calculate Cross Wavelet Spectra----------------------------
% ---- between dependent variable and independent variables------
for i=1:(col-1)
Wyx=Y.*conj(XS1(:,:,i));
sWyx=smoothwavelet(sinv(:,ones(1,n)).*Wyx,dt,period,Args.Dj,scale);
sWyx1(:,:,i)=sWyx;
end
% ----between independent variables and independent variables------
for i=1:(col-1);
for j=1:(col-1);
Wxx=XS1(:,:,i).*conj(XS1(:,:,j));
sWxx=smoothwavelet(sinv(:,ones(1,n)).*Wxx,dt,period,Args.Dj,scale);
sWxx1(:,:,i,j)=sWxx;
end
end
% --------------- Mutiple wavelet coherence ---------------------------------
% calculate the multiple wavelet coherence
for i=1:length(scale)
parfor j=1:n
a=transpose(squeeze(sWyx1(i,j,:)));
b=inv(squeeze(sWxx1(i,j,:,:)));
c=conj(squeeze(sWyx1(i,j,:)));
d=smY(i,j);
Rsq(i,j)=real(a*b*c/d);
end
end
% --------------- make figure--------------------------------------------
if (nargout>0)||(Args.MakeFigure)
    mwcsig=mwcsignif(Args.MonteCarloCount,Args.AR1,dt,length(t)*2,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother,.
6);
mwcsig=(mwcsig(:,2))*(ones(1,n));
mwcsig=Rsq./mwcsig;
end
if Args.MakeFigure
Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
if Args.BlackandWhite
levels = [0 0.5 0.7 0.8 0.9 1];
[cout,H]=safecontourf(t,log2(period),Rsq,levels);
colorbarf(cout,H)
cmap=[0 1;.5 .9;.8 .8;.9 .6;1 .5];
cmap=interp1(cmap(:,1),cmap(:,2),(0:.1:1)');
cmap=cmap(:,[1 1 1]);
colormap(cmap)
set(gca,'YLim',log2([min(period),max(period)]), ...
'YDir','reverse', 'layer','top', ...
'YTick',log2(Yticks(:)), ...
'YTickLabel',num2str(Yticks'), ...
'layer','top');
ylabel('Period');
hold on
if ~all(isnan(mwcsig))
[c,h] = contour(t,log2(period),mwcsig,[1 1],'k');%#ok
set(h,'linewidth',2);
end
%suptitle([sTitle ' coherence']);
%plot(t,log2(coi),'k','linewidth',2)
tt=[t([1 1])-dt*.5;t;t([end end])+dt*.5];
%hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]));
%hatching- modified by Ng and Kwok
hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
hatch(hcoi,45,[0 0 0]);
hatch(hcoi,135,[0 0 0]);
set(hcoi,'alphadatamapping','direct','facealpha',.5);
plot(t,log2(coi),'color','black','linewidth',1.5);
hold off
else
H=imagesc(t,log2(period),Rsq);%#ok
%[c,H]=safecontourf(t,log2(period),Rsq,[0:.05:1]);
%set(H,'linestyle','none')
set(gca,'clim',[0 1]);
HCB=safecolorbar;%#ok
set(gca,'YLim',log2([min(period),max(period)]), ...
'YDir','reverse', 'layer','top', ...
'YTick',log2(Yticks(:)), ...
'YTickLabel',num2str(Yticks'), ...
'layer','top');
ylabel('Period');
hold on
if ~all(isnan(mwcsig))
[c,h] = contour(t,log2(period),mwcsig,[1 1],'k');%#ok
set(h,'linewidth',2);
end
%suptitle([sTitle ' coherence']);
tt=[t([1 1])-dt*.5;t;t([end end])+dt*.5];
hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
set(hcoi,'alphadatamapping','direct','facealpha',.5);
hold off
end
end
%---------------------------------------------------------------%
varargout={Rsq,period,scale,coi,mwcsig};
varargout=varargout(1:nargout);
function [cout,H]=safecontourf(varargin)
vv=sscanf(version,'%i.');
if (version('-release')<14)|(vv(1)<7)
[cout,H]=contourf(varargin{:});
else
[cout,H]=contourf('v6',varargin{:});
end
function hcb=safecolorbar(varargin)
vv=sscanf(version,'%i.');
if (version('-release')<14)|(vv(1)<7)
hcb=colorbar(varargin{:});
else
hcb=colorbar('v6',varargin{:});
ends