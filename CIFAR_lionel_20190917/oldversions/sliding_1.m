%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sliding window metrics for time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% nobs   - number of observations
% fs     - sampling frequency (Hz)
% tseg   - time segment specification (see 'timeseg.m')
% wlen   - window length (seconds)
% slen   - slide length (seconds)
% tstamp - window time stamp specification: 'start', 'mid', or 'end' of window
% verb   - verbosity flag
%
% Outputs:
%
% nwin   - number of windows
% noobs  - offset observations (number of observations before first window)
% nwobs  - number of observations in a window
% nsobs  - number of observations to slide window
% nobs   - total number of observations from start of first to end of last window
% t      - vector of time stamps for windows (seconds - see 'tstamp' input)
% tseg   - total time segment: start time of first window and end time of last window (2-vector, seconds)
% obs    - vector of observation indices from start of first to end of last window
% oseg   - start and end observation indices (2-vector)
% tlen   - total time length (seconds)
% wlen   - window length (seconds)
% slen   - slide length (seconds)
%
% Again (see 'timeseg.m'), negative values in 'tseg', 'wlen' and 'slen' are interpreted as
% observation indices/numbers rather than times.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use as follows:
%
% [nwin,noobs,nwobs,nsobs,nobs,t,tseg,obs,oseg,tlen,wlen,slen] = sliding(nobs,fs,tseg,wlen,slen,tstamp,verb);
%
% for w = 1:nwin
% 	fprintf('window %4d of %d\n',w,nwin);
% 	o = noobs+(w-1)*nsobs;   % window offset
% 	W = X(:,o+1:o+nwobs);    % the window
%
%   *** do something with window W ***
%
% end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nwin,noobs,nwobs,nsobs,nobs,t,tseg,obs,oseg,tlen,wlen,slen] = sliding(nobs,fs,tseg,wlen,slen,tstamp,verb)

if nargin < 3,                    tseg   = [];      end
if nargin < 6 || isempty(tstamp), tstamp = 'start'; end % time stamp beginning, mid-point, or end of window
if nargin < 7 || isempty(verb),   verb   = 0;       end

[~,nobs,oseg] = timeseg(nobs,fs,tseg,0);

if wlen < 0, nwobs = -wlen; else, nwobs = round(fs*wlen)+1; end
if slen < 0, nsobs = -slen; else, nsobs = round(fs*slen);   end

wlen = (nwobs-1)/fs;
slen = nsobs/fs;

noobs = oseg(1)-1;

nwin = floor((nobs-nwobs)/nsobs)+1; % number of windows

nobs = nwobs + (nwin-1)*nsobs; % new number of observations
tlen = (nobs-1)/fs;            % new length of data (secs)

nover = nwobs-nsobs;
tover = (nover-1)/fs;

oseg = [noobs+1 noobs+nobs];
tseg = (oseg-1)/fs;

obs = (oseg(1):oseg(2))'; % observations

switch lower(tstamp)
	case 'start', t = (noobs + nsobs*((0:(nwin-1))'))/fs;           % marks *startpoint* of window
	case 'mid',	  t = (noobs + nsobs*((0:(nwin-1))') + nwobs/2)/fs; % marks *midpoint*   of window
	case 'end',   t = (noobs + nsobs*((0:(nwin-1))') + nwobs)/fs;   % marks *endpoint*   of window
	otherwise, error('Unknown time stamp specification');
end

if verb > 0
	fprintf('\nnumber of windows = %d\n',nwin);
	fprintf('-----------------------------------------------\n');
	fprintf('total   : %7d observations  = %8.3f secs\n',nobs,tlen);
	fprintf('start   : %7d observations  = %8.3f secs\n',oseg(1),tseg(1));
	fprintf('end     : %7d observations  = %8.3f secs\n',oseg(2),tseg(2));
	fprintf('window  : %7d observations  = %8.3f secs\n',nwobs,wlen);
	fprintf('slide   : %7d observations  = %8.3f secs\n',nsobs,slen);
	fprintf('overlap : %7d observations  = %8.3f secs\n',nover,tover);
	fprintf('-----------------------------------------------\n\n');
	if verb > 1, input('RETURN to continue: '); end
end

assert(nwin > 0,'Bad windows');
