%% Preprocess the data using butternotch filter and plot psd
function tsdata_pp=tsdata2preprocessed(tsdata,ds,fc,fs,fres,order)
%fc: cut off frequency
%fs: sampling rate
%fres: frequency resolution
%order: order of the butternotch filter
%ds: downsampling factor
%% High pass Filtering the signal :
fn=fs/2; %Nyquist frequency
[b,a]=butter(order,fc/fn,'high'); %Butterworth High pass filter
%fvtool(b,a); visualise filter
tsdata_filt=filtfilt(b,a,tsdata); %Zero phase filtering in forward and backward direction
%% Downsampling
tsdata_pp=downsample(tsdata_filt,ds,[]);
%% Compute cpsd (autospec mean we compute the autospectral density)
[cpsd_filt,f,fres] = tsdata_to_cpsd(tsdata_pp,[],fs,[],[],fres,'True',[]); %Filtered
%[cpsd,f,fres] = tsdata_to_cpsd(X,[],fs,[],[],fres,'True',[]); %Unfiltered
%% Plot cpsd
%filtered cpsd
figure(1); 
loglog(f,cpsd_filt)
xlabel('Frequency')
ylabel('Spectral density')
legend('Filtered Spectral density function')
end