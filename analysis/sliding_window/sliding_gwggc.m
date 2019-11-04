%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate intra-ROI multi-information conditional on rest of system, over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run 'sliding_varmo' first

if ~exist('regmode',   'var'), regmode   = 'LWR';  end % AR model estimation regression mode
if ~exist('mosel',     'var'), mosel     = 1;      end % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
if ~exist('verb',      'var'), verb      = 2;      end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;      end % figure number
if ~exist('figsave',   'var'), figsave   = false;  end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xchans = 1:length(chans); % selected channels in X

% Slide window

F = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[A,V] = tsdata_to_var(W,moest(w,mosel),regmode);
	F(w) = var_to_gwggc(A,V,{xchans});
	fprintf('F = % 6.4f\n',F(w));
end

if ~isempty(fignum)

	center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(tsw,F);
	xlim([ts(1) ts(end)]);
	ylabel('Global GC');
	xlabel('time (secs)');

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
