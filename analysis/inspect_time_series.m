%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inspect time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = 0;     end % selected channels (0 for all, empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = 0 ;    end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [];    end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false; end % data file too large to read into memory
if ~exist('nrm',       'var'), nrm       = 0;     end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('verb',      'var'), verb      = 1;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BP = 1; subject = 'AnRa'; task = 'rest_baseline_1'; schans=0; numchan=1; tseg= [80 85]; ppdir     = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';

[X, ts, EEG, filepath,filename,chanstr,fs]=import_tsdata(BP, subject, task, schans, numchan, tseg, badchans,ds, ppdir);
[nchans,nobs] = size(X);

%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

plot(ts',X');

xlabel('time (secs)');
ylabel('ECoG');
xlim([ts(1) ts(end)]);

chanstr      = strsplit(chanstr);
chanstr      = strjoin(chanstr,'_');
fig_filename = [filename,'_ROI_',num2str(-schans),'_',ppdir,'_',chanstr];
fig_title    = strsplit(fig_filename,'_');
fig_title    = strjoin(fig_title,' ');
fig_filepath = [pwd, '/figures/time_series_inspection/'];
title(fig_title)
saveas(gcf,[fig_filepath,fig_filename,'.fig']);

