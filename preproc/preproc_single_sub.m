%% Preprocess single sub
% TODO : Update EEGlab version https://sccn.ucsd.edu/wiki/How_to_download_EEGLAB
%        Find out how to do automated cleaning https://github.com/sccn/clean_rawdata/blob/master/pop_clean_rawdata.m
%        Get rid of bad epochs manually
%        ICA and see if it helps
%        Run SS modeling on cleaned data
%       

subject = 'AnRa';
%% Import data (EEG structure with SUMA and data)
[X, ts, EEG, filepath,filename,chanstr]=import_ecogdata(subject, 'ppdir','nopreproc');

%% Visualise time series annotate
pop_eegplot(EEG);
%% ICA ? 

%% Drop bad channels 
drop_chans = [1, 40:51, 59, 60, 61]; % Hyppocampal and unknown regions
EEG =  pop_select(EEG, 'nochannel', drop_chans); % Would be interesting to keep track of ROI
X = EEG.data;


%% Clean data
EEG = clean_rawdata(EEG, arg_flatline, arg_highpass, arg_channel, arg_noisy, arg_burst, arg_window);
X = clean_asr(X,cutoff,windowlen,stepsize,maxdims,ref_maxbadchannels,ref_tolerances,ref_wndlen,usegpu,useriemannian,maxmem);
%% Detrending

%% Gaussianity
for i = 2:58
    pop_signalstat(EEG, 1,i)
end
%% Autospectral density

%% SS modeling on sliding window (for stationarity)

%% Save preprocessed data 
