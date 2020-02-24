%% Spectral analysis, plot cpsd of time series
%% Preprocessed
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
tsdata_ROI=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx);
%% Slide window 
window_size=100000;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
tsdata_slided=tsdata2slided(tsdata_ROI, window_size,num_chan,tsdata_length);
%% Remove outliers
num_window=size(tsdata_slided,3);
for i=1:num_window
    sdfac=3.5; 
    madfac=8;
    repmean='False';
    repmed='False';
    ts_picked=tsdata_slided(:,:,i);
    [ts_madout,outs]=routl_m(ts_picked,madfac,repmed);
    [ts_out,nouts] = routl(ts_picked,sdfac,repmean);
    %% Compute cpsd (autospec=True mean we compute the autospectral density)
    [cpsd_filt,f,fres] = tsdata_to_cpsd(ts_out,[],fs,[],[],fres,'True',[]); 
    %% Plot cpsd
    path2save='/its/home/gc349/CIFAR_guillaume/plots/AnRa/spectral_analysis'
    %filtered cpsd
    figure; 
    loglog(f,cpsd_filt)
    xlabel('Frequency')
    ylabel('Spectral density')
    title([num2str(fc) ' Hz filtered cpsd, AnRa, resting raw data, ' num2str(window_size/500) 's window, outl, all ROI'])
    filename=strcat('cpsd_',num2str(window_size/500),'sw_3.5sdfac_1fc_rest_raw_allROI_window',num2str(i));
    saveas(gca, fullfile(path2save, filename), 'png');
    close
end