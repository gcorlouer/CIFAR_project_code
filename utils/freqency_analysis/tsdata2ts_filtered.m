%% Filter data
% Use fvtool(bp_filt) to look at filter response.
function tsdata_filtered=tsdata2ts_filtered(tsdata, filter)
%% Arguments
% tsdata    : time series input
% fcut_low  : low cut freq
% fcut high : high cut freq
% filt_order :filter order
[nchan,nobs]=size(tsdata);

tsdata_filtered = zeros(size(tsdata));

for i = 1:nchan
    tsdata_filtered(i, :) = filter(bpFilt, 1, tsdata(i, :));
end