%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slide state space modeling along a sliding window on CIFAR, simulated or
% envelope
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('schans',    'var'),       schans         = -11 ;                                             end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'),       badchans       = 0 ;                                               end % bad channels (empty for none)
if ~exist('tseg',      'var'),       tseg           = [10 60];                                          end % start/end times (empty for entire time series)
if ~exist('ds',        'var'),       ds             = 1;                                                end % downsample factor
if ~exist('bigfile',   'var'),       bigfile        = false;                                            end % data file too large to read into memory
if ~exist('wind',      'var'),       wind           = [10 0.1];                                         end % window width and slide time (secs)
if ~exist('tstamp',    'var'),       tstamp         = 'mid';                                            end % window time stamp: 'start', 'mid', or 'end'
if ~exist('fres',      'var'),       fres           = 1024;                                             end % frequency resolution
if ~exist('verb',      'var'),       verb           = 0;                                                end % verbosity: display channel info
if ~exist('fignum',    'var'),       fignum         = 1;                                                end % figure number
if ~exist('simorder',  'var'),       simorder       = 5;                                                end % morder for simulation
if ~exist('data',      'var'),       data           = 'CIF';                                            end % 
if ~exist('subject',   'var'),       subject        = 'AnRa';                                           end %
if ~exist('task',   'var'),          task           = 'rest_baseline_1';                                end % 
if ~exist('BP',        'var'),       BP             = 0;                                                end % BP=-1 for simulated data
if ~exist('numchan',   'var'),       numchan_BP     = 10;                                               end %number of channel for BP 
if ~exist('ppdir',     'var'),       ppdir          = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; end %preproc directory
if ~exist('fig_path_tail',   'var'), fig_path_tail  = '/figures/stationarity/ssmodeling/';              end %path 2 save figure
if ~exist('iband',   'var'),         HFB            = 0;                                                end
if ~exist('iband',   'var'),         iband          = 2;                                                end
if ~exist('band_low',   'var'),      band_low       = 60;                                               end
if ~exist('band_size',   'var'),     band_size      = 20;                                               end
if ~exist('nband',   'var'),         nband          = 5;                                                end
if ~exist('filt_order',   'var'),    filt_order     = 138;                                              end
if ~exist('tsdim',   'var'),         tsdim          = numchan_BP;                                       end
if ~exist('morder',   'var'),        morder         = 5;                                                end
if ~exist('specrad',   'var'),       specrad        = 0.98;                                             end
if ~exist('nobs',   'var'),          nobs           = 100000;                                           end
if ~exist('fs',   'var'),            fs             = 500 ;                                             end
if ~exist('g',   'var'),             g              = [] ;                                              end
if ~exist('w',   'var'),             w              = [] ;                                              end
if ~exist('ntrials',   'var'),       ntrials        = 1 ;                                               end
if ~exist('checkcpsd',   'var'),     checkcpsd      = 0 ;                                               end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import data

if data=='CIF'
    [X, ts, EEG, filepath,filename,chanstr] = import_ecogdata(BP, subject, task, schans, numchan_BP, tseg, badchans,ds, ppdir);
    [nchans,nobs]                           = size(X);
    fig_filetail=[filename,'_BP_',num2str(BP),'_ROI_',num2str(-schans),'_','_wind_',num2str(wind(1)),'s_',ppdir(1:7),'_numchanBP_',num2str(numchan_BP)];
elseif data=='sim' %simulate VAR model
    [X,ts,var_coef,corr_res]                = var_sim(numchan_BP, simorder);
    fig_filetail=['varsim_morder_',num2str(simorder),'_numchanBP_',num2str(numchan_BP)];
end



%% Check cpsd

if checkcpsd==1
    fhi=250;

    [S,f,fres] = tsdata_to_cpsd(X,false,fs,[],[],fres,true,false); % auto-spectra
    S          = 20*log10(S); % measure power as log-mean across channels (dB)


    %center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

    semilogx(f,S);

    xlabel('frequency (Hz)');
    ylabel('power (dB)');
    xlim([0 fhi]);
    grid on
else
    
end

%% IF HFB=1 then extract envelope 
if HFB==1
    [envelope_band,band] = tsdata2HFB(X,fs,band_low,band_size,nband,filt_order);
    X                    = envelope_band(:,:,iband);
    fig_filetail=[filename,'_band_',num2str(iband*band_size+band_low),'Hz_''_BP_',num2str(BP),'_ROI_',num2str(-schans),...
        '_','_wind_',num2str(wind(1)),'s_',ppdir(1:7),'_numchanBP_',num2str(numchan_BP)];
else
    
end

%% Run state space model analysis

[rhoa,rhob,mii,moest,mosvc] = fun_slide_ssmodel(X,ts,fig_filetail,fs,wind,HFB,fig_path_tail);

clear all