%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line-noise sinusoidal fit detrend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lnoise = lntrend(X,fs,lnfreqs)

[nchans,nobs] = size(X);

nlnfreqs = length(lnfreqs);

X = X';

lnoise = zeros(nobs,nchans);
for k = 1:nchans
	for i = 1:nlnfreqs % run through frequencies
		fln = sinufitf(X(:,k),fs,lnfreqs(i));               % fit line-noise frequency precisely
		lnoise(:,k) = lnoise(:,k)+sinufits(X(:,k),fs,fln);  % line-noise signal for channel
	end
end
lnoise = lnoise';
