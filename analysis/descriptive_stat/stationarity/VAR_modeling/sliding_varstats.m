%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate AR model stats over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run 'sliding_varmo' first

if ~exist('regmode',   'var'), regmode   = 'OLS';  end % AR model estimation regression mode
if ~exist('mosel',     'var'), mosel     = 1;      end % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
if ~exist('verb',      'var'), verb      = 2;      end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;      end % figure number
if ~exist('figsave',   'var'), figsave   = false;  end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rho = zeros(nwin,1);
mii = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[A,V] = tsdata_to_var(W,moest(w,mosel),regmode);
	info = var_info(A,V,0);
	rho(w) = info.rho;
	mii(w) = info.mii;
	fprintf('rho = %6.4f, mii = %6.4f\n',rho(w),mii(w));
end

if ~isempty(fignum)

	center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	yyaxis left
	plot(tsw,rho);
	ylabel('spectral radius');
	yyaxis right
	plot(tsw,mii);
	xlim([ts(1) ts(end)]);
	ylabel('residuals multi-information');
	xlabel('time (secs)');

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
