function [mosvc,pf]=sliding_ssmorder(X,ts,nwin,nsobs,nwobs,tsw,moest,mosel)

if nargin < 8 mosel =1; end % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT

pf = 2*moest(:,mosel); % (Bauer: 2*aic for mosel == 1)

mosvc = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[mosvc(w),ssmomax] = tsdata_to_ssmo(W,pf(w));
	fprintf('mosvc = %d\n',mosvc(w));
end

%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

plot(tsw,mosvc);
ylabel('SS model order');
xlim([ts(1) ts(end)]);
xlabel('time (secs)');
