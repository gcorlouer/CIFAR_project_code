%% Extract analytic envelope of a signal
% Might also use matlab envelop function
function envelope = tsdata2envelope(tsdata)
%% Arguments
%tsdata: input signal (usually a time series)
%% 
nchan       = size(tsdata,1); %tsdata must have format nchans x samples
tsdata_anal = zeros(size(tsdata));
envelope    = zeros(size(tsdata_anal));
for i = 1:nchan
    tsdata_anal(i,:) = hilbert(tsdata(i,:)); %extract analytic signal
    envelope(i,:)    = abs(tsdata_anal(i,:));
end