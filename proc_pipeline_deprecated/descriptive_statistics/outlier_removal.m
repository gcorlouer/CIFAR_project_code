%% Remove outliers and VAR model
%% Preproces
tsdata=double(EEG.data); 
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
filt_order=1;
dsample=1;  
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order); %filter and downsample
%% Select chans
pick_ROI=1:1:22;
pick_ROI=pick_ROI';
pick_chan=[];
[tsdata_ROI,pick_chan]=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx);
%% Slide window
window_size=10000;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
tsdata_slided=tsdata2slided(tsdata_ROI, window_size,num_chan,tsdata_length);
%% Remove outliers
sdfac=3.5; 
madfac=8;
repmean='False';
repmed='False';
ts_picked=tsdata_slided(:,:,1);
[ts_madout,outs]=routl_m(ts_picked,madfac,repmed);
[ts_out,nouts] = routl(ts_picked,sdfac,repmean);
%% Plot time series
%figure
%plot_tsdata(ts_out,[],[],[]);
%% VAR modeling
momax=75;
moregmode='LWR';
regmode   = 'OLS'; 
num_window=size(tsdata_slided,3);
ptic('\n*** tsdata_to_varmo... ');
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(ts_out,momax,moregmode);
ptoc;
%morder=input('morder=');
morder=moselect('BIC','AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
%% VAR estimation and spectral radius 
spectral_radius=zeros(num_window,1);
ptic('\n*** tsdata_to_var... ');
[A,V] = tsdata_to_var(ts_out,morder,regmode);
ptoc;
% Check for failed regression
assert(~isbad(A),'VAR estimation failed - bailing out');
info = var_info(A,V);
assert(~info.error,'VAR error(s) found - bailing out');
spectral_radius(i,1)=info.rho;
%% Write results in a structure
j=68;
results(j).ROI_num=size(pick_ROI,1);
results(j).chan_num=size(pick_chan,2);
results(j).window_size=window_size;
results(j).highpass=fc;
results(j).dsample=dsample;
results(j).madfac=madfac;
results(j).sdfac=sdfac;
results(j).regmode={regmode};
results(j).morder=morder;
results(j).moregmode=moregmode;
results(j).specrad=info.rho;