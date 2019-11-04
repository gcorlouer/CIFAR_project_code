%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% High-pass (Butterworth) zero-phase filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function X = hpfilter(X,fs,hpfreq,hpord)

[b,a] = butter(hpord,hpfreq/fs,'high');
if ~isstable  (b,a),fprintf(2,'*** WARNING: high-pass filter not stable\n');        end
if ~isminphase(b,a),fprintf(2,'*** WARNING: high-pass filter not minimum-phase\n'); end

%	rho = specnorm(-a(2:end))
%	trobs = ceil((-log(eps))/(-log(rho)))
%	trlen = trobs/fs

X = filtfilt(b,a,X')'; % zero-phase filter
