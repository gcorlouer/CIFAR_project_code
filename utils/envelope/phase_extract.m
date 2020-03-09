%Extract phase for CIFAR data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = 0;       end % bad channels (empty for none, 0 to get rid of them)
if ~exist('tseg',      'var'), tseg      = [];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false;    end % data file too large to read into memory
if ~exist('wind',      'var'), wind      = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp    = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('sd1',       'var'), sd1       = 3.0;   end % outlier std. dev. 1
if ~exist('nrm',       'var'), nrm       = 0;     end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('sd2',       'var'), sd2       = 4.0;   end % outlier std. dev. 1
if ~exist('verb',      'var'), verb      = 2;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BP = 0; subject = 'AnRa'; task = 'rest_baseline_1';  ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';

schans=-6;
[chans,chanstr,channames] = select_channels(BP,subject,task,schans,badchans,verb);

[tsdata,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,verb);

if nrm > 0,	if nrm > 1, tsdata = demean(tsdata,true); else, tsdata = demean(tsdata,false); end; end

[nchans,nobs] = size(tsdata);

[fs,fcut_low,fcut_high,filt_order, iir]=deal(500,90,110,128,0);
tsdata_filtered=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, iir);
phase=tsdata2phase(tsdata_filtered);
trange=1:250;
plot(trange,phase(1:3,trange))
dt=1/fs; 
xt = get(gca, 'XTick');                                 
set(gca, 'XTick', xt, 'XTickLabel', xt/fs)  
xlabel('Time (sec)')
ylabel('Phase')
[filepath,filename] = CIFAR_filename(BP,subject,task);
title(plot_title(filename,ppdir,chanstr,mfilename,fs),'Interpreter','none');
save_fig(mfilename,filename,filepath,figsave);