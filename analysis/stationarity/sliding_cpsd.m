function [s,tsw,wind]=sliding_cpsd(X,ts,wind,tstamp,verb,fs,fres,fhi,ftinc,ttinc)
%Estimates autocpsd along sliding windows

if nargin < 3 wind     =[5 0.1] ;  end % window width and slide time (secs)
if nargin < 4 tstamp   = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if nargin < 5 verb     = 2;        end % verbosity
if nargin < 7 fs       = 500;      end % sampling rate
if nargin < 7 fres     = 1024;     end % frequency resolution
if nargin < 8 fhi      = 100;      end % highest frequency to display (Hz)
if nargin < 9 ftinc    = 20;       end % frequency tick increment (Hz)
if nargin < 10 ttinc   = 20;       end % time tick increment (secs)

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

s = zeros(fres+1,nwin);      % mean auto-power across selected channels
for w = 1:nwin               % count windows
	fprintf('window %4d of %d\n',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	S = tsdata_to_cpsd(W,false,fs,[],[],fres,true,false); % auto-spectra
	s(:,w) = mean(20*log10(S),2); % measure power as log-mean across channels (dB)
end

%center_fig(fignum,[1760,1024]);  % create, set size (pixels) and center figure window

fq   = fs/2;       % Nyqvist frequency
ttix = round(ts(1):ttinc:ts(end)); % time ticks (secs)
ftix = 0:ftinc:fq; % where we want the frequency ticks (Hz)
ffac = fres/fq;    % convert y-values to frequencies (Hz);

subplot(1,2,1);
imagesc(s);
colormap('jet');
colorbar;
xticks(ttix);      xticklabels(num2cell(ttix));
yticks(ffac*ftix); yticklabels(num2cell(ftix));
xlim([ts(1) ts(end)]);
ylim([0 ffac*fhi])
%	caxis(subplot(1,2,1),[-11 120]) % to set colour axis limits
xlabel('time (secs)');
ylabel('frequency (Hz)');

f = (0:fres)*(fq/fres); % frequency scale

subplot(1,2,2);
semilogx(f,s);
xlim([1 0.999*fq]);
xlabel('frequency (Hz, logscale)');
ylabel('mean log-autopower (dB)');

