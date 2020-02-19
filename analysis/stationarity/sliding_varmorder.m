function moest=sliding_varmorder(X,ts,nwin,nsobs,nwobs,tsw,moregmode,maxmo)
%Estimates var model along sliding window

if nargin < 7 moregmode = 'LWR'; end
if nargin < 8 maxmo     = 20;    end

moest = zeros(nwin,4);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs; % window offset
	W = X(:,o+1:o+nwobs);  % the window
	[moest(w,1),moest(w,2),moest(w,3),moest(w,4)] = tsdata_to_varmo(W,maxmo,moregmode);
	fprintf('AIC = %2d, BIC = %2d, HQC = %2d, LRT = %2d\n',moest(w,1),moest(w,2),moest(w,3),moest(w,4));
end

plot(tsw,moest);
xlim([ts(1) ts(end)]);
xlabel('time (secs)');
ylabel('VAR model order');
legend({'AIC','BIC','HQC','LRT'});