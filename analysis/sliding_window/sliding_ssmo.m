%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate AR model orders over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run 'sliding_varmo' first

if ~exist('mosel',     'var'), mosel     = 1;     end % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pf = 2*moest(:,mosel); % (Bauer: 2*aic for mosel == 1)

mosvc = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[mosvc(w),ssmomax] = tsdata_to_ssmo(W,pf(w));
	fprintf('mosvc = %d\n',mosvc(w));
end

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	figure(fignum); clf;
	plot(tsw,mosvc);
	ylabel('SS model order');
	xlim([ts(1) ts(end)]);
	xlabel('time (secs)');

	[filepath,filename] = CIFAR_filename(BP,subject,task);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
