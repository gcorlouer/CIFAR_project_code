%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return time segment metrics for time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% nobs   - number of observations
% fs     - sampling frequency (Hz)
% tseg   - time segment specification (see below)
% verb   - verbosity flag
%
% Outputs:
%
% obs    - vector of observation indices
% nobs   - number of observations
% oseg   - start and end observation indices (2-vector)
% t      - vector of time stamps (seconds)
% tlen   - time length (seconds)
% tseg   - time segment (2-vector, seconds)
%
% 'tseg' input is in the form of an ascending 2-vector (start and end times in
% seconds). Negative values are interpreted as observation indices rather than
% times; tseg(1) = 0 specifies the beginning of a time series, and t(2) = Inf
% specifies up till the end of a times series. 'tseg' can also be is a 3-vector;
% in this case, tseg(2) is interpreted as a time length rather than an end time.
% Time segment is truncated if final observation is beyond end of time series.
% Empty 'tseg' specifies the entire time series.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [obs,nobs,oseg,t,tlen,tseg] = timeseg(nobs,fs,tseg,verb)

if nargin < 4 || isempty(verb), verb = 0;  end

off2 = false;
if nargin < 3 || isempty(tseg)
	tseg = [0 Inf];
%elseif isscalar(tseg)
% 	tseg(1) = tseg;
% 	tseg(2) = Inf;
else
	assert (isvector(tseg),'Time segment must be an ascending 2- or 3-vector (or empty)');
	if length(tseg) == 3
		off2 = true; % tseg(2) represents  length (in time or observations)
		tseg = tseg([1 2]);
	else
		assert (length(tseg) == 2,'Time segment must be an ascending 2- or 3-vector (or empty)');
	end
end

% If negative, treat tseg(i) as observation numbers rather than times

if tseg(1) < 0
	oseg(1) = -tseg(1);
else
	oseg(1) = round(fs*tseg(1))+1;
end

% If 'off2' set, interpret tseg(2) as length (in time or observations)

if off2
	if tseg(2) < 0
		oseg(2) = oseg(1)+oseg(2)-1;
	else
		oseg(2) = round(fs*(tseg(1)+tseg(2)))+1;
	end
else
	if tseg(2) < 0
		oseg(2) = -tseg(2);
	else
		oseg(2) = round(fs*tseg(2))+1;
	end
end

if oseg(1) < 1,    oseg(1) = 1;    end; % truncate to beginning
if oseg(2) > nobs, oseg(2) = nobs; end; % truncate to end

% Got oseg

nobs = oseg(2)-oseg(1)+1; % number of observations
assert(nobs > 0,'Bad times');
obs = (oseg(1):oseg(2))'; % observations

% Recalculate tseg

tseg = (oseg-1)/fs;
tlen = (nobs-1)/fs; % = tseg(2)-tseg(1)

t = (obs-1)/fs; % time stamps of observations

if verb > 0
	fprintf('\n-----------------------------------------------\n');
	fprintf('total   : %7d observations  = %8.3f secs\n',nobs,tlen);
	fprintf('start   : %7d observations  = %8.3f secs\n',oseg(1),tseg(1));
	fprintf('end     : %7d observations  = %8.3f secs\n',oseg(2),tseg(2));
	fprintf('-----------------------------------------------\n\n');
	if verb > 1, input('RETURN to continue: '); end
end
