%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inspect time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('subject',   'var'),  subject  = 'AnRa';             end %
if ~exist('task',   'var'),     task     = 'rest_baseline_1';  end % 
if ~exist('BP',        'var'),       BP             = 1;       end % BP=-1 for simulated data
if ~exist('schans',    'var'), schans    = 0;     end % selected channels (0 for all, empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = 0 ;    end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [50 100];    end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false; end % data file too large to read into memory
if ~exist('nrm',       'var'), nrm       = 0;     end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('verb',      'var'), verb      = 0;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('tseg',      'var'), tseg           = [10 30]; end % start/end times (empty for entire time series)
if ~exist('schans',      'var'), schans         = 0 ;    end % start/end times (empty for entire time series)
if ~exist('ppdir',     'var'),   ppdir          = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; end %preproc directory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[chans,chanstr] = select_channels(BP,subject,task,schans); 
[X, ts,fs]=load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,verb);
[nchans,nobs] = size(X);

%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

plot(ts',X');

xlabel('time (secs)');
ylabel('ECoG');
xlim([ts(1) ts(end)]);

chanstr      = strsplit(chanstr);
chanstr      = strjoin(chanstr,'_');
% fig_filename = [filename,'_ROI_',num2str(-schans),'_',ppdir,'_',chanstr];
% fig_filepath = [pwd, '/figures/time_series_inspection/'];
% title(fig_title)
% saveas(gcf,[fig_filepath,fig_filename,'.fig']);

