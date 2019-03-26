%% PLot filtered spectral density, downsample and highpass over 1HZ
%Pick channels 
X=double(EEG.data); %double precision
n_chan=size(X,1);
%X=X(1:n_chan,:);
fres=2^11;
fs=EEG.srate;
%% High pass Filtering the signal
fc=1; %cutoff frequency
fn=fs/2; %Nyquist frequency
order=2; %Filter order : unclear what to chose here 
[b,a]=butter(order,fc/fn,'high'); %Butterworth High pass filter
fvtool(b,a);
X_pp=filtfilt(b,a,X); %Zero phase filtering in forward and backward direction
%% Downsampling
X_pp=downsample(X,4,[]);
%% Compute cpsd (autospec mean we compute the autospectral density)
[S_filt,f,fres] = tsdata_to_cpsd(X_pp,[],fs,[],[],fres,'True',[]); %Filtered
%[S,f,fres] = tsdata_to_cpsd(X,[],fs,[],[],fres,'True',[]); %Unfiltered
%% Plot cpsd
%filtered cpsd
figure(1); 
loglog(f,S_filt)
xlabel('Frequency')
ylabel('Spectral density')
legend('Filtered Spectral density function')
% %unfiltered
% figure 
% loglog(f,S)
% xlabel('Frequency')
% ylabel('Spectral density')