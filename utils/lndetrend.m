%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line-noise sinusoidal fit detrend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X,mnsr] = lndetrend(X,fs,lnfreqs)

nchans = size(X,1);

nlnfreqs = length(lnfreqs);

mnsrs = nan(nchans,nlnfreqs);
for k = 1:nchans
	x = X(k,:)';
	for i = 1:nlnfreqs % run through frequencies
		fln = sinufitf(x,fs,lnfreqs(i)); % fit line-noise frequency precisely
		lnoise = sinufits(x,fs,fln);     % line-noise signal for channel
		x = x-lnoise;                    % remove line-noise
		mnsrs(k,i) = var(lnoise)/var(x); % line-noise-to-signal power ratio
	end
	X(k,:) = x';
end
mnsr = nanmean(mnsrs); % mean (across channels) of line-noise-to-signal power ratios
