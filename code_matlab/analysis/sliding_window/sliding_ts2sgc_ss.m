function [wsgc,wsgcint]=sliding_ts2sgc_ss(X,nwin,nsobs,nwobs,fband,fs, nfbin)

if nargin < 7 nfbin = 1024 ; end  
if nargin < 6 fs    = 500 ; end

nfpt  = nfbin+1 ;
nchan = size(X,1);

wsgc    = zeros(nwin,nchan,nchan,nfpt);
wsgcint = zeros(nwin,nchan,nchan);

for w = 1:nwin
	o = (w-1)*nsobs; % window offset
	W = X(:,o+1:o+nwobs);  % the window
	wsgc(w,:,:,:)  = ts2sgc_ss(W); %can add more output arguments if want parameters such that A,C,K etc
    wsgcint(w,:,:) = bandlimit(wsgc(w,:,:,:),4,fs,fband);
end
