%% Phase extraction from analytic signal from inpute time series
%On VAR signal seems to output constant phase
function phase=tsdata2phase(tsdata)

tsdim = size(tsdata,1);
tsanal = zeros(size(tsdata));
phase = zeros(size(tsdata));

for i=1:tsdim
    tsanal(i,:) = hilbert(tsdata(i,:)); %create analytique signal
    phase(i,:) = angle(tsanal(i,:));
end