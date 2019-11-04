%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sliding window stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nwin,dlen,ndobs,wlen,nwobs,slen,nsobs,olen,noobs,t] = sliding(ntobs,fs,wlen,slen,olen,verb)

if nargin < 5 || isempty(olen), olen = 0; end
if nargin < 6 || isempty(verb), verb = 1; end

tlen = ntobs/fs;

if wlen < 0                         % -(observations in window)
	nwobs = -wlen                   % number of observations in window
else
	nwobs = round(fs*wlen);         % number of observations in window
end
wlen = nwobs/fs;                    % length of window (secs)

if slen < 0                         % -(observations to slide)
	nsobs = -slen                   % number of observations to slide
else
	nsobs = round(fs*slen);         % number of observations to slide
end
slen = nsobs/fs;                    % offset time (secs)

assert(nsobs <= nwobs,'Sliding windows don''t overlap!');

if olen < 0                         % -(offset observations)
	noobs = -olen                   % number of observations to offset
else
	noobs = round(fs*olen);         % number of observations to offset
end
olen = noobs/fs;                    % offset time (secs)

assert(nwobs <= ntobs-noobs,'Window/offset too large!');

nwin = floor((ntobs-noobs-nwobs)/nsobs)+1; % number of windows

ndobs = nwobs + (nwin-1)*nsobs;     % new number of observations
dlen  = ndobs/fs;                   % new length of data (secs)

if verb > 0
	fprintf('\nnumber of windows = %d\n',nwin);
	fprintf('-----------------------------------------------\n');
	fprintf('old tot : %7d observations  = %8.3f secs\n',ntobs,tlen);
	fprintf('new tot : %7d observations  = %8.3f secs\n',ndobs,dlen);
	fprintf('window  : %7d observations  = %8.3f secs\n',nwobs,wlen);
	fprintf('sliding : %7d observations  = %8.3f secs\n',nsobs,slen);
	fprintf('overlap : %7d observations  = %8.3f secs\n',nwobs-nsobs,wlen-slen);
	fprintf('offset  : %7d observations  = %8.3f secs\n',noobs,olen);
	fprintf('-----------------------------------------------\n\n');
	if verb > 1, input('RETURN to continue: '); end
end

if nargout > 9
	t = olen+(0:(nwin-1))'*(nsobs/fs); % time stamp for starts of windows
end

% Slide window
%
% for w = 1:nwin
% 	fprintf('window %4d of %d\n',w,nwin);
% 	o = noobs+(w-1)*nsobs;   % window offset
% 	W = X(:,o+1:o+nwobs);    % the window
%   *** do something with window ***
% end
