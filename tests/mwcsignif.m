function mwcsig=mwcsignif(mccount,ar1,dt,n,pad,dj,s0,j1,mother,cutoff)
% Multiple Wavelet Coherence Significance Calculation (Monte Carlo)
%
% mwcsig=mwcsignif(mccount,ar1,dt,n,pad,dj,s0,j1,mother,cutoff)
%
% mccount: number of time series generations in the monte carlo run
%(the greater the better)
% ar1: a vector containing two (in case of calculating wavelet
% coherence between two variables) or
% multiple (≥3) (in case of calculating multiple wavelet coherence
% with three or more variables)
% AR1 coefficients.
% dt,pad,dj,s0,j1,mother: see wavelet help...
% n: length of each generated timeseries. (obsolete)
%
% cutoff: (obsolete)
%
% RETURNED
% mwcsig: the 95% significance level as a function of scale... (scale,sig95level)
% -----------------------------------------------------------
% Please acknowledge the use of this software package in any publications,
% by including text such as:
%
% "The software for the multiple wavelet coherence was provided by W. Hu
% and B. Si, and is available in the supplement of Hu and Si (2016)."
% and cite the paper:
% "Hu, W., and B. Si (2016), Technical Note: Multiple wavelet coherence for untangling scale-specific and localized
% multivariate relationships in geosciences, Hydrol. Earth Syst. Sci., volume and page numbers to be allocated ."
%
% (C) W. Hu and B. C. Si 2016
%
% -----------------------------------------------------------
%
% Copyright (C) 2016, W. Hu and B. C. Si 2016
% This software may be used, copied, or redistributed as long as it is not
% sold and this copyright notice is reproduced on each copy made. This
% routine is provided as is without any express or implied warranties
% whatsoever.
%
% Wavelet software was provided by C. Torrence and G. Compo,
% and is available at URL: http://paos.colorado.edu/research/wavelets/.
%
% Crosswavelet and wavelet coherence software were provided by
% A. Grinsted and is available at URL:
% http://www.glaciology.net/wavelet-coherence
%
%
% We acknowledge Aslak Grinsted for his code (wtcsignif.m) on
% which this code builds.
%
%---------------------------------------------------------------------
cachedir=fileparts(mfilename('fullpath'));
cachedir=fullfile(cachedir,'.cache');
%we don't need to do the monte carlo if we have a cached
%siglevel for ar1s that are almost the same. (see fig4 in Grinsted et al., 2004)
aa=round(atanh(ar1(:)')*4); %this function increases the sensitivity near 1 & -1
aa=abs(aa)+.5*(aa<0); %only positive numbers are allowed in the checkvalues (because of log)
% do a check that it is not the same as last time... (for optimization purposes)
checkvalues=single([aa dj s0/dt j1 double(mother)]); %n & pad are not important.
%also the resolution is not important.
checkhash=['' mod(sum(log(checkvalues+1)*127),25)+'a' mod(sum(log(checkvalues+1)*54321),25)+'a'];
cachefilename=fullfile(cachedir,['mwcsignif-cached-' checkhash '.mat']);
%the hash is used to distinguish cache files.
try
last=load(cachefilename);
if (last.mccount>=mccount) && (isequal(checkvalues,last.checkvalues))
mwcsig=last.mwcsig;
return
end
catch
end
%choose a n so that largest scale have atleast some part outside the coi
ms=s0*(2^(j1*dj))/dt; %maxscale in units of samples
n=ceil(ms*6);
warned=0;
%precalculate stuff that's constant outside the loop
%d1=ar1noise(n,1,ar1(1),1);
d1=rednoise(n,ar1(1),1);
[W1,period,scale,coi] = wavelet(d1,dt,pad,dj,s0,j1,mother);
outsidecoi=zeros(size(W1));
for s=1:length(scale)
outsidecoi(s,:)=(period(s)<=coi);
end
sinv=1./(scale');
sinv=sinv(:,ones(1,size(W1,2)));
if mccount<1
mwcsig=scale';
mwcsig(:,2)=.71; %pretty good
return
end
sig95=zeros(size(scale));
maxscale=1;
for s=1:length(scale)
if any(outsidecoi(s,:)>0)
maxscale=s;
else
sig95(s)=NaN;
if ~warned
warning('Long wavelengths completely influenced by COI. (suggestion: set n higher, or j1 lower)');
warned=1;
end
end
end
%PAR1=1./ar1spectrum(ar1(1),period');
%PAR1=PAR1(:,ones(1,size(W1,2)));
%PAR2=1./ar1spectrum(ar1(2),period');
%PAR2=PAR2(:,ones(1,size(W1,2)));
nbins=1000;
wlc=zeros(length(scale),nbins);
wbh = waitbar(0,['Running Monte Carlo (significance)... (H=' checkhash ')'],'Name','Monte Carlo (MWC)');
for ii=1:mccount
waitbar(ii/mccount,wbh);
dy=rednoise(n,ar1(1),1);
[Wdy,period,scale,coiy] = wavelet(dy,dt,pad,dj,s0,j1,mother);
sinv=1./(scale');
smdY=smoothwavelet(sinv(:,ones(1,n)).*(abs(Wdy).^2),dt,period,dj,scale);
col=size(ar1,2);
for i=2:col
dx=rednoise(n,ar1(i),1);
[Wdx,period,scale,coix] = wavelet(dx,dt,pad,dj,s0,j1,mother);
Wdx1(:,:,(i-1))=Wdx;
end
% -------- Calculate Cross Wavelet Spectra----------------------------
% ----between dependent variable and independent variables------
parfor i=1:(col-1)
Wdyx=Wdy.*conj(Wdx1(:,:,i));
sWdyx=smoothwavelet(sinv(:,ones(1,n)).*Wdyx,dt,period, dj,scale);
sWdyx1(:,:,i)=sWdyx;
end
% ----between independent variables and independent variables------
for i=1:(col-1);
parfor j=1:(col-1);
Wdxx=Wdx1(:,:,i).*conj(Wdx1(:,:,j));
sWdxx=smoothwavelet(sinv(:,ones(1,n)).*Wdxx,dt,period,dj,scale);
sWdxx1(:,:,i,j)=sWdxx;
end
end
% calculate the multiple wavelet coherence
for i=1:length(scale)
parfor j=1:n
a=transpose(squeeze(sWdyx1(i,j,:)));
b=inv(squeeze(sWdxx1(i,j,:,:)));
c=conj(squeeze(sWdyx1(i,j,:)));
d=smdY(i,j);
Rsq(i,j)=real(a*b*c/d);
end
end
for s=1:maxscale
cd=Rsq(s,find(outsidecoi(s,:)));
cd=max(min(cd,1),0);
cd=floor(cd*(nbins-1))+1;
for jj=1:length(cd)
wlc(s,cd(jj))=wlc(s,cd(jj))+1;
end
end
end
close(wbh);
for s=1:maxscale
rsqy=((1:nbins)-.5)/nbins;
ptile=wlc(s,:);
idx=find(ptile~=0);
ptile=ptile(idx);
rsqy=rsqy(idx);
ptile=cumsum(ptile);
ptile=(ptile-.5)/ptile(end);
sig95(s)=interp1(ptile,rsqy,.95);
end
mwcsig=[scale' sig95'];
if any(isnan(sig95))&(~warned)
warning('Sig95 calculation failed. (Some NaNs)');
else
try
save(cachefilename,'mccount','checkvalues','mwcsig'); %save to a cache....
catch
warning(['Unable to write to cache file: ' cachefilename]);
end
end