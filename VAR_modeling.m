%% Parameters initialisation 
%% Preprocessed
tsdata=double(EEG.data); 
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
filt_order=2;
dsample=1;
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order); %filter and downsample
%% Select chans
pick_ROI=1:1:22;
pick_ROI=pick_ROI';
pick_chan=[];
tsdata_ROI=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx);
%% Slide window 
window_size=2000;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
tsdata_slided=tsdata2slided(tsdata_ROI, window_size,num_chan,tsdata_length);
%% Model order estimation (<mvgc_schema.html#3 |A2|>)
% Calculate and plot VAR model order estimation criteria up to specified maximum model order.
path2save='CIFAR_guillaume/plots/AnRa/VAR_modeling';
momax=25;
moregmode='LWR';
regmode   = 'LWR'; 
num_window=size(tsdata_slided,3);
morders=zeros(num_window,1);
errlow=zeros(size(morders));
errhigh=zeros(size(morders));
for i=1:num_window-1
    ptic('\n*** tsdata_to_varmo... ');
    [moaic,mobic,mohqc,molrt] = tsdata_to_varmo(squeeze(tsdata_slided(:,:,i)),momax,moregmode);
    ptoc;
    morders(i,1)=moselect('HQC','AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
    LRT=moselect('LRT','AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
    BIC=moselect('BIC','AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
    errlow(i,1)=morders(i,1)-BIC;
    errhigh(i,1)=LRT-morders(i,1);
end 
%% Barplot model orders with uncertainty bars
figure;
sliding_window=1:num_window;
bar(sliding_window,morders)                
hold on
er = errorbar(sliding_window,morders,errlow,errhigh);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
hold off
title(['Model orders along',num2str(window_size/fs),' sec silding window, AnRa, rest, raw'])
xlabel('Sliding window')
ylabel('Model order')
filename=strcat('morder_ROI_2sw');
saveas(gca, fullfile(path2save, filename), 'png');
close
%% VAR estimation and spectral radius 
spectral_radius=zeros(num_window,1);
for i=1:num_window-1
    ptic('\n*** tsdata_to_var... ');
    [A,V] = tsdata_to_var(squeeze(tsdata_slided(:,:,i)),morders(i,1),regmode);
    ptoc;
% Check for failed regression
    assert(~isbad(A),'VAR estimation failed - bailing out');
% Report information on the estimated VAR, and check for errors.
% _IMPORTANT:_ We check the VAR model for stability and symmetric
% positive-definite residuals covariance matrix. _THIS CHECK SHOULD ALWAYS BE
% PERFORMED!_ - subsequent routines may fail if there are errors here. If there
% are problems with the data (e.g. non-stationarity, colinearity, etc.) there's
% also a good chance they'll show up at this point - and the diagnostics may
% supply useful information as to what went wrong.
    info = var_info(A,V);
    assert(~info.error,'VAR error(s) found - bailing out');
    spectral_radius(i,1)=info.rho;
end
figure;
bar(sliding_window,spectral_radius);
title('Spectral radius along silding window')
xlabel('Sliding window')
ylabel('Spectral radius')
ylim([0.8,1])
filename=strcat('specrad_ROI_2sw');
saveas(gca, fullfile(path2save, filename), 'png');
close;