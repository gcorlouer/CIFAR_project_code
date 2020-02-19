function [X, ts, EEG, filepath,filename,chanstr,fs,envelope_band,band,var_coef,corr_res]=try_import_tsdata(BP, subject, task, schans, numchan, tseg, badchans,ds, ppdir,...
HFB,iband,band_low,band_size,nband,filt_order,tsdim, morder, specrad, nobs, fs, g, w, ntrials)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Import CIFAR time series or simulate VAR data and extract envelope
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 23 ntrials = 1 ;                                                end
if nargin < 22 w      = [] ;                                                end 
if nargin < 21 g      = [] ;                                                end
if nargin < 20 fs     = 500;                                                end
if nargin < 19 nobs   = 100000;                                             end
if nargin < 18 specrad= 0.98 ;                                              end
if nargin < 17 morder = 5;                                                  end
if nargin < 16 tsdim  = 10;                                                 end
if nargin < 15 filt_order = 138;                                            end
if nargin < 14 nband   = 5 ;                                                end
if nargin < 13 band_size=20;                                                end
if nargin < 12 band_low= 60 ;                                               end
if nargin < 11 iband   = 2 ;                                                end
if nargin < 10 HFB     = 0 ;                                                end
if nargin < 9 ppdir    = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';  end %preproc dir
if nargin < 8 ds       = 1;                                                 end %no downsample
if nargin < 7 badchans = 0 ;                                                end %take only good chans                                        
if nargin < 6 tseg     = [1 50];                                            end
if nargin < 5 numchan  = [];                                                end
if nargin < 4 schans   = 0;                                                 end 

cd CIFAR_data/iEEG_10/subjects;
    
if BP==0
    [EEG,filepath,filename] = get_EEG_info(BP,subject,task);
    [chans,chanstr] = select_channels(BP,subject,task,schans,badchans);
    [X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds);
    var_coef = 'NaN';
    corr_res = 'NaN';

elseif BP==1
    [EEG,filepath,filename] = get_EEG_info(BP,subject,task);
    chans=randi([1 EEG.nbchan],[numchan 1]); %Chose channels at random
    schans=chans(1); %NO ROI available so far. To not break the code just take first channel number
    chanstr = sprintf('channels%s',sprintf(' %d',chans));
    [X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds);
    var_coef = 'NaN';
    corr_res = 'NaN';
else %simulated data
    [X,ts,var_coef,corr_res] = var_sim(tsdim, morder,specrad, nobs, fs, g, w, ntrials);
end

if HFB==1
    [envelope_band,band]=tsdata2HFB(X,fs,band_low,band_size,nband,filt_order);
    X=envelope_band(:,:,iband);
else 
    envelope_band = 'NaN';
    band          = 'NaN';
end
cd ..; cd ..; cd ..