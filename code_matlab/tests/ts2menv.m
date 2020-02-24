%% Output multidimensional time series made of envelope at diferent frequency bands
%% Param
%% TODO
%% 
function [multi_envelope,ts_bpass,fcl,fch]=ts2menv(tsdata, fcl_init, nbands, band_step,fs,filt_order,iir)
nobs=size(tsdata,2);
tsdim=size(tsdata,1);
fcl=zeros(nbands,1);
fch=zeros(nbands,1);
fcl(1)=fcl_init;
fch(1)=fcl_init+band_step;

if nbands>1
    for i=1:nbands-1
    fcl(i+1)=fcl(i)+band_step;
    end
else
    fcl(1)=fcl_init;
end

if nbands>1
    for i=1:nbands-1
    fch(i+1)=fch(i)+band_step;
    end
else
    fch(1)=fch_init;
end

ts_bpass=zeros(tsdim,nobs,nbands);
for i=1:nbands
    ts_bpass(:,:,i)=tsdata2ts_filtered(tsdata,fs,fcl(i),fch(i),filt_order, iir);
end

multi_envelope=zeros(tsdim,nobs,nbands);
for i=1:nbands
    multi_envelope(:,:,i)=tsdata2envelope(squeeze(ts_bpass(:,:,i)));
end