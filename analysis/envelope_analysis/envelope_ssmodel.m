%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slide state space modeling along a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('schans',    'var'), schans   = -11 ;     end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans = 0 ;       end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg     = [1 60];   end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds       = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile  = false;    end % data file too large to read into memory
if ~exist('wind',      'var'), wind     = [10 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp   = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('fres',      'var'), fres     = 1024;     end % frequency resolution
if ~exist('verb',      'var'), verb     = 0;        end % verbosity: display channel info
if ~exist('fignum',    'var'), fignum   = 1;        end % figure number
if ~exist('simorder',  'var'), simorder = 5;        end % morder for simulation
if ~exist('data',      'var'), data     = 'CIFAR';  end % 
if ~exist('subject',   'var'), subject  = 'AnRa';   end %
if ~exist('task',   'var'),    task     = 'rest_baseline_1';   end % 
if ~exist('BP',        'var'), BP       = 1;        end % BP 
if ~exist('numchan',   'var'), numchan_BP  = 10;    end %number of channel for BP 
if ~exist('ppdir',     'var'), ppdir    = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';       end %preproc directory
if ~exist('fig_path_tail',   'var'), fig_path_tail  = '/figures/stationarity/ssmodeling/';       end %path 2 save figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import data
if data=='CIFAR'
    [X, ts, EEG, filepath,filename,chanstr,fs]=import_tsdata(BP, subject, task, schans, numchan_BP, tseg, badchans,ds, ppdir);
    [nchans,nobs] = size(X);
else %simulate VAR model
    [X,var_coef,corr_res] = var_sim(numchan_BP, simorder);
end
%Name tail of figure file 2 save
fig_filetail=[filename,'_ROI_',num2str(-schans),'_','_wind_',num2str(wind(1)),'s_',ppdir(1:7),'_numchanBP_',num2str(numchan_BP)]; 

%% Extract envelope

[envelope_band,band]=tsdata2HFB(X,fs,band_low,band_size,nband,filt_order);
envelope=envelope_band(:,:,iband);

%% Slice time series

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind);
%% VAR model order

moest=sliding_varmorder(X,ts,nwin,nsobs,nwobs,tsw);

fig_filename = ['varmorder_slide_',fig_filetail];
fig_filepath = [pwd, fig_path_tail]; %check that path is correct

saveas(gcf,[fig_filepath,fig_filename,'.fig']);
close all
%% State space model order

[mosvc,pf]=sliding_ssmorder(X,ts,nwin,nsobs,nwobs,tsw,moest)

fig_filename = ['ssmordel_slide_', fig_filetail];
fig_filepath = [pwd, fig_path_tail]; %check that path is correct

saveas(gcf,[fig_filepath,fig_filename,'.fig']);
close all
%% SS model statistics

[rhoa,rhob,mii]= ss_mostat(X,ts,mosvc,pf,nwin,nsobs,nwobs,tsw);

fig_filename = ['ssmodel_slide_', fig_filetail];
fig_filepath = [pwd, fig_path_tail]; %check that path is correct

saveas(gcf,[fig_filepath,fig_filename,'.fig']);
close all

clear all