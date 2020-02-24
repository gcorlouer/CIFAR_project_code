%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sliding window metrics for time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% X      - time series data (channels x observations)
% ts     - data time stamp vector (secs)
% fs     - sampling frequency (Hz)
% wind   - window width and slide time (secs)
% tstamp - window time stamp specification: 'start', 'mid', or 'end' of window
% verb   - verbosity flag
%
% Outputs:
%
% X      - time series data (channels x observations) - may be truncated
% ts     - data time stamp vector (secs) - may be truncated
% nwin   - number of windows
% nwobs  - number of observations in a window
% nsobs  - number of observations to slide window
% tsw    - window time stamp vector (seconds - see 'tstamp' input)
% wind   - window width and slide time (secs) - may be adjusted
%
% As in 'utils/load_tsdata.m', negative values in 'wind' are interpreted as
% observation indices/numbers rather than times.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use as follows:
%
% [X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);
%
% for w = 1:nwin
% 	fprintf('window %4d of %d\n',w,nwin);
% 	o = (w-1)*nsobs;      % window offset
% 	W = X(:,o+1:o+nwobs); % the window
%
%   *** do something with window W ***
%
% end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb)

if nargin < 5 || isempty(tstamp), tstamp = 'mid'; end % time stamp beginning, mid-point, or end of window
if nargin < 6 || isempty(verb),   verb   = 0;     end

assert(isvector(wind) && length(wind) == 2,'Sliding window specification must be a 2-vector');

wlen = wind(1);
slen = wind(2);

nobs = length(ts);

if wlen < 0, nwobs = -wlen; else, nwobs = round(fs*wlen)+1; end
if slen < 0, nsobs = -slen; else, nsobs = round(fs*slen);   end

wlen = (nwobs-1)/fs;
slen = nsobs/fs;

nwin = floor((nobs-nwobs)/nsobs)+1; % number of windows

nobs = nwobs + (nwin-1)*nsobs; % new number of observations

o = 1:nobs;
X  = X(:,o);
ts = ts(o);

tlen = (nobs-1)/fs;            % new length of data (secs)

nover = nwobs-nsobs;
tover = (nover-1)/fs;

wind = [wlen slen];

switch lower(tstamp)
	case 'start', tsw = ts(1)+(nsobs*((0:(nwin-1))'))/fs;           % marks *startpoint* of window
	case 'mid',	  tsw = ts(1)+(nsobs*((0:(nwin-1))') + nwobs/2)/fs; % marks *midpoint*   of window
	case 'end',   tsw = ts(1)+(nsobs*((0:(nwin-1))') + nwobs)/fs;   % marks *endpoint*   of window
	otherwise, error('Unknown time stamp specification');
end

if verb > 0
	fprintf('\nnumber of windows = %d\n',nwin);
	fprintf('-----------------------------------------------\n');
	fprintf('total   : %7d observations  = %8.3f secs\n',nobs,tlen);
	fprintf('window  : %7d observations  = %8.3f secs\n',nwobs,wlen);
	fprintf('slide   : %7d observations  = %8.3f secs\n',nsobs,slen);
	fprintf('overlap : %7d observations  = %8.3f secs\n',nover,tover);
	fprintf('-----------------------------------------------\n');
	if verb > 1, input('RETURN to continue: '); end
end

assert(nwin > 0,'Bad windows');
