%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sliding trend merge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The merge function, 'mergefunc' should be a sigmoid defined on [0,1] and returning a value in [0,1].
%
% 'varargin' are the parameters to the window trend function, 'terndfunc';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function trend = sliding_merge(X,nwins,nwobs,nsobs,trendfunc,mergefunc,verb,varargin)

nover = nwobs-nsobs; % window overlap
assert(nover > 0,'No overlap!');
m = mergefunc((1:nover)/(nover+1)); % merge weights

trend = zeros(size(X));
for w = 1:nwin % loop through windows
	if verb, fprintf('window %4d of %d',w,nwin); end
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	wtrend = trendfunc(W,verb,varargin);
	if w == 1
		trend(:,1:nwobs) = wtrend; % initialise - copy first window
	else
		trend(:,o+1:o+nover) = (1-m).*trend(:,o+1:o+nover) + m.*wtrend(:,1:nover); % merge window on overlap
		trend(:,o+nover+1:o+nwobs) = wtrend(:,nover+1:nwobs);                      % copy remainder of window
	end
	if verb, fprintf('\n'); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% E.g.,
%
% function m = hamming_mergefunc(x) % window merge function ("Hamming sigmoid")
%
%	m = (1-cos(pi*x))/2;
%
% end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
