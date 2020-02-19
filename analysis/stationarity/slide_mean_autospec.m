%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make heatmap of spectrum over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all 

if ~exist('schans',    'var'), schans   = 0 ;       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans = 0 ;       end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg     = [40 140];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds       = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile  = false;    end % data file too large to read into memory
if ~exist('nrm',       'var'), nrm      = 0;        end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('wind',      'var'), wind     = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp   = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('fres',      'var'), fres     = 1024;     end % frequency resolution
if ~exist('fhi',       'var'), fhi      = 160;      end % highest frequency to display (Hz)
if ~exist('ftinc',     'var'), ftinc    = 20;       end % frequency tick increment (Hz)
if ~exist('ttinc',     'var'), ttinc    = 20;       end % time tick increment (secs)
if ~exist('verb',      'var'), verb     = 2;        end % verbosity
if ~exist('fignum',    'var'), fignum   = 1;        end % figure number
if ~exist('figsave',   'var'), figsave  = false;    end % save .fig file(s)?
if ~exist('fig_path_tail',   'var'), fig_path_tail  = '/figures/envelope/';       end %path 2 save figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import data
BP = 1; subject = 'AnRa'; task = 'rest_baseline_1'; schans=0; numchan=20; ppdir = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';

[X, ts, EEG, filepath,filename,chanstr,fs]=import_tsdata(BP, subject, task, schans, numchan, tseg, badchans,ds, ppdir);
[nchans,nobs] = size(X);
%Name tail of figure file 2 save
fig_filetail=[filename,'_ROI_',num2str(-schans),'_','_wind_',num2str(wind(1)),'s_',ppdir(1:7),'_numchanBP_',num2str(numchan_BP)]; 
%% Slice time series
wind=[5 0.1]
[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind);
%% Slide cpsd
s=sliding_cpsd(X,ts,wind)


fig_filename = ['slide_mean_autospec',fig_filetail];
fig_filepath = [pwd, fig_path_tail]; %check that path is correct

saveas(gcf,[fig_filepath,fig_filename,'.fig']);