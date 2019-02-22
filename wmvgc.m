%Compute Granger causality of multivariate chopped off time series x in time amd spectal domain with a translating
%time window of size n_f-n_i, incrementing by wlag each step to cover the all time series (so time windows may overlap)
%chan_i is initial chanel, chan_f is final channel
function [F_time,F_spec,morders, WAR_spectral_radius]=wmvgc(x,n_i,n_f,wlag,Nobs,nchan,chan_i,chan_f)%eventually add F_spec for spectral MVGC
%mf=50000
freqs=2049;
n_lags=floor((Nobs-n_f)/wlag);%Nobs is the number of observations
F_time=zeros(nchan, nchan,n_lags); %Array recording all MCGC value at each lag step in time domain
F_spec=zeros(nchan,nchan,freqs,n_lags); %Array recording all MCGC value at each lag step in frequency domain
morders=zeros(1,n_lags);%record model orders at each lags
WAR_spectral_radius=zeros(1,n_lags);%record spectral radius at each lags
for j=1:n_lags
    X=x(chan_i:chan_f,n_i:n_f);%Chop off the data
    run mvgc_demo.m;
    morders(1,j)=morder;%Record model orders
    WAR_spectral_radius(j)=info.rho;%Record spectral radius
    F_time(:,:,j)=F;%Record time GC
    F_spec(:,:,:,j)=f;%Record spectral GC
    n_i=n_i+wlag;%increment time window
    n_f=n_f+wlag;
end

