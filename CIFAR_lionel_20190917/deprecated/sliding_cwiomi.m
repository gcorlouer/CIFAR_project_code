%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate mean and standard deviation over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify (preprocessed) data to load

if ~exist('schans',    'var'), schans    = [];    end % selected channels (empty for all good, negative for ROI number)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('wlen',      'var'), wlen      = 5;     end % length of window (secs)
if ~exist('slen',      'var'), slen      = 0.1;   end % window slide time (secs)
if ~exist('olen',      'var'), olen      = 0;     end % offset time (secs)
if ~exist('ttinc',     'var'), ttinc     = 20;    end % time tick increment (secs)
if ~exist('verb',      'var'), verb      = 2;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[schans,chanstr,channames] = chan_select(subject,schans);
fprintf('\nUsing %s\n',chanstr);

[XX,FS,filepath,filename] = load_preproc(BP,subject,name,ppdir);

X = downsample(XX(schans,:),ds);
clear XX
fs = FS/ds;

[nchans,nobs] = size(X);

[nwin,dlen,ndobs,wlen,nwobs,slen,nsobs,olen,noobs,t] = sliding(nobs,fs,wlen,slen,olen,verb);

% Slide window

I = zeros(nwin,nchans);
Imean = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = noobs+(w-1)*nsobs; % window offset
	W = X(:,o+1:o+nwobs);  % the window
	V = tsdata_to_autocov(W,0);
	I(w,:) = cov_to_cwiomi(V);
	Imean(w) = mean(I(w,:)); % mean across channels
	fprintf('mean = % 6.4f\n',Imean(w));
end

if ~isempty(fignum)

	figure(fignum); clf
	pos = get(gcf,'Position');
	set(gcf,'Position',[pos(1),pos(2),[1280,1280]]); % set size (pixels)

	subplot(2,1,1);
	plot(t,Imean);
	xlim([0 t(end)]);
	ylabel('mean GMI');
	xlabel('time (secs)');

	ttix = 0:ttinc:dlen; % where we want the time ticks (secs)
	tfac = nsobs/fs;     % convert x-values to times (secs)
	ctix = 1:nchans;     % where we want the channel ticks

	subplot(2,1,2);
	imagesc(I');
	colormap('jet');
	colorbar;
	xticks(ttix/tfac); xticklabels(num2cell(ttix));
	yticks(ctix);      yticklabels(channames);
	%ylim([0 fhi/ffac])
	xlabel('time (secs)');
	ylabel('channel');
	sgtitle(sprintf('%s (%s)\n%s\n%s : sample rate = %gHz, windows %gs, slide %gs\n',filename,ppdir,chanstr,mfilename,fs,wlen,slen),'Interpreter','none');

	if figsave, save_fig(mfilename,filename,filepath); end
end
