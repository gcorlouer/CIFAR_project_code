%% Preprocess the data using butternotch filter and plot psd
function tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order)
%fc: cut off frequency
%fs: sampling rate
%fres: frequency resolution
%order: order of the butternotch filter
%ds: downsampling factor
%% High pass Filtering the signal :
fn=fs/2; %Nyquist frequency
[b,a]=butter(filt_order,fc/fn,'high'); %Butterworth High pass filter
%fvtool(b,a); visualise filter
tsdata_filt=filtfilt(b,a,tsdata); %Zero phase filtering in forward and backward direction
%% Downsampling
tsdata_pp=downsample(tsdata_filt,dsample,[]);
