%% Filter data
% Use fvtool(bp_filt) to look at filter response.
function tsdata_filtered=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, iir)
%% Arguments
% tsdata    : time series input
% fcut_low  : low cut freq
% fcut high : high cut freq
% filt_order :filter order
%% TODO : add condition to Check if filter is minimum phase with flag = isminphase(bp_filt)
%%
if nargin < 6 iir = 0; end
if iir == 1 
    bp_filt = designfilt('bandpassiir','FilterOrder',filt_order, ...
         'HalfPowerFrequency1',fcut_low,'HalfPowerFrequency2',fcut_high, ...
         'SampleRate',fs);
else
    bp_filt = designfilt('bandpassfir','FilterOrder',filt_order, ...
         'CutoffFrequency1',fcut_low,'CutoffFrequency2',fcut_high, ...
         'SampleRate',fs);
end
tsdata_filtered = zeros(size(tsdata));
nchan           = size(tsdata,1);
for i = 1:nchan
    tsdata_filtered(i,:) = filter(bp_filt,tsdata(i,:));
end 