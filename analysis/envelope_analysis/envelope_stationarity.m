%Envelope stationarity
%% Pick up data and channels
% Analyse mean and std in all ROI
fig_filepath= [pwd, '/figures/stationarity/'];
cd '~/CIFAR_guillaume' %CIFAR directory
cd 'CIFAR_data/iEEG_10/subjects' %Subject dir
BP = 0; subject = 'AnRa'; task = 'rest_baseline_1';
figsave=false;
tseg      = [1 50];     % start/end times (empty for entire time series)
ds=1;

if BP==0
    ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';
    schans    = -11;      % selected channels (0 for all good, negative for ROI number)
    badchans  = 0;       % bad channels (empty for none)
    [EEG,filepath,filename] = get_EEG_info(BP,subject,task);
    [chans,chanstr] = select_channels(BP,subject,task,schans,badchans,1);
    [X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg);

else
    ppdir='preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';
    numchan=10 %Pick numchan random channels
    %nobs=25000;
    [EEG,filepath,filename] = get_EEG_info(BP,subject,task);
    chans=randi([1 EEG.nbchan],[numchan 1]);
    schans=chans(1); %NO ROI available so far. To not break the code just take first channel number
    chanstr = sprintf('channels%s',sprintf(' %d',chans));
    [X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds);
end
cd ..; cd ..; cd .. ;
%% Extract envelope
nband=5;
band=zeros(nband,1);
band_step=20;
band(1)=60;
for iband=1:nband-1
    band(iband+1)=band(iband)+band_step;
end
iir=0;
[fs,fcut_low,fcut_high,filt_order, fir]=deal(500,band(2),band(3),138,0);
X=tsdata2ts_filtered(X,fs,fcut_low,fcut_high,filt_order, iir);
X = tsdata2envelope(X); %%Envelope extraction
%% Check cpsd
%So far 2 channels seems spurious looking at cpsd, since we randomly pick
%them, it is worth checking if they are ok
fhi=250;
fres=2014;
[S,f,fres] = tsdata_to_cpsd(X,false,fs,[],[],fres,true,false); % auto-spectra
S = 20*log10(S); % measure power as log-mean across channels (dB)


%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

semilogx(f,S);

xlabel('frequency (Hz)');
ylabel('power (dB)');
xlim([0 fhi]);
grid on
%% Slice time series
fs=500; wind=[10 0.1];
[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind);
%Prepare title for figures
tail_fig_filename=[filename,'_envelope_','_BP_',num2str(BP),'_ROI_',num2str(-schans),'_wind_',num2str(wind(1)),'s.fig'];
close all
%% Slide cpsd
s=sliding_cpsd(X,ts,wind);
fig_filename=['sliding_mean_autospectra_',tail_fig_filename];
% fig_title=strsplit(fig_filename,'_'); 
% title(fig_title)
saveas(gcf,[fig_filepath,fig_filename]);
%close all
%% VAR model order
moest=sliding_varmorder(X,ts,nwin,nsobs,nwobs,tsw);
fig_filename=['varmorder_',tail_fig_filename];
% fig_title=[fig_title,', VAR model order estimation along ',num2str(wind(1)),'s',' sliding window '];
% title(fig_title)
saveas(gcf,[fig_filepath,fig_filename]);
close all
%% State space model order
[mosvc,pf]=sliding_ssmorder(X,ts,nwin,nsobs,nwobs,tsw,moest) %default moselection is AIC

fig_filename=['ss_model_order_',tail_fig_filename];
% fig_title=[fig_title,', VAR model order estimation along ',num2str(wind(1)),'s',' sliding window '];
% title(fig_title)
saveas(gcf,[fig_filepath,fig_filename]);
close all
%% SS model statistics
[rhoa,rhob,mii]= ss_mostat(X,ts,mosvc,pf,nwin,nsobs,nwobs,tsw);

fig_filename=['SS_model_specrad_',tail_fig_filename];
% fig_title=[fig_title,', VAR model order estimation along ',num2str(wind(1)),'s',' sliding window '];
% title(fig_title)
saveas(gcf,[fig_filepath,fig_filename]);
close all