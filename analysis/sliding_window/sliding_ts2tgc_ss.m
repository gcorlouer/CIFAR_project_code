function wtgc = sliding_ts2tgc_ss(X,nwin,nsobs,nwobs)

if nargin < 7 nfbin = 1024 ; end  
if nargin < 6 fs    = 500 ; end

nchan = size(X,1);

wtgc    = zeros(nwin,nchan,nchan);

for w = 1:nwin
	o = (w-1)*nsobs; % window offset
	W = X(:,o+1:o+nwobs);  % the window
	wtgc(w,:,:,:) = ts2tgc_ss(W); %can add more output arguments if want parameters such that A,C,K etc
end
