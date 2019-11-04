%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polynomial fit detrend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X,wflag,P] = pfdetrend(X,fs,pford)

[nchans,nobs] = size(X);

t = (0:nobs-1)'/fs; % time scale

[X,mu,sig] = demean(X,true); % normalise for improved stability

X = X';
P = zeros(nobs,nchans);
w = warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
lastwarn('');
wflag = false;
for i = 1:nchans
	p = polyfit(t,X(:,i),pford);
	if ~isempty(lastwarn), wflag = true; end
	P(:,i) = polyval(p,t);
end
lastwarn('');
warning(w);

X = sig.*X'+mu; % de-normalise
P = sig.*P'+mu; % de-normalise

X = X-P; % subtract polynomial trend
