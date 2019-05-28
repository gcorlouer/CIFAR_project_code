%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make heatmap of spectrum over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify channels in 'schans';

if ~exist('wlen',  'var'), wlen  = 2;    end % length of window (secs)
if ~exist('wsli',  'var'), wlen  = 0.2;  end % window slide time (secs)
if ~exist('fres',  'var'), fres  = 1024; end % frequency resolution

gpterm = 'x11';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('xloaded','var') || ~xloaded
	[EEG,filename,filepath] = load_EEG(false,'AnRa','freerecall_rest_baseline_1_preprocessed');
	XX = EEG.data;
	fs = EEG.srate;
	clear EEG
	xloaded = true;
end

X = XX(schans,:);
[nchans,nobs] = size(X);

dlen = nobs/fs;                     % data total time (secs)

if wlen < 0                         % -(observations in window)
	nwobs = -wlen                   % number of observations in window
else
	nwobs = round(fs*wlen);         % number of observations in window
end
wlen = nwobs/fs;                    % length of window (secs)

if wsli < 0                         % -(observations to slide)
	nsobs = -wsli                   % number of observations to slide
else
	nsobs = round(fs*wsli);         % number of observations to slide
end
wsli = nsobs/fs;                    % window slide time (secs)

nwin = floor((nobs-nwobs)/nsobs)+1; % number of windows

% t = (0:(nwin-1))'*(nsobs/fs);
% f = linspace(0,fs/2,h)';

% Slide window

s = zeros(fres+1,nwin);      % mean auto-power across selected channels
for w = 1:nwin               % count windows
	fprintf('window %4d of %d\n',w,nwin);
	o = (w-1)*nsobs;         % window offset
	W = X(:,o+1:o+nwobs);    % the window
	S = tsdata_to_cpsd(W,false,fs,[],[],fres,true,false); % auto-spectra
	s(:,w) = mean(log(S),2); % measure power as log-mean across channels
end

ttix = 0:20:dlen;   % where we want the time ticks (secs)
tfac = nsobs/fs;    % convert x-values to times (secs)
ftix = 0:20:fs/2;   % where we want the frequency ticks (Hz)
fhi  = 100;         % highest frequency to display (Hz)
ffac = (fs/2)/fres; % convert y-values to frequencies (Hz);

figure(1); clf;
imagesc(s);
colormap('jet');
colorbar;
xticks(ttix/tfac); xticklabels(num2cell(ttix));
yticks(ftix/ffac); yticklabels(num2cell(ftix));
ylim([0 fhi/ffac])
xlabel('time (secs)');
ylabel('frequency (Hz)');
title(sprintf('AnRa (raw, freerecall\\_rest\\_baseline\\_1\\_preprocessed)\nspectrum, %g-sec windows\n',wlen));
