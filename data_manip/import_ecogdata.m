function [X, ts, EEG, filepath,filename,chanstr]=import_ecogdata(BP, subject, task, schans, tseg, badchans,ds, ppdir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Import CIFAR time series 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 8 ppdir    = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';  end %preproc dir
if nargin < 7 ds       = 1;                                                 end %no downsample
if nargin < 6 badchans = 0 ;                                                end %take only good chans                                        
if nargin < 5 tseg     = [1 50];                                            end
if nargin < 4 schans   = 0;                                                 end 

    
[EEG,filepath,filename] = get_EEG_info(BP,subject,task);
[chans,chanstr] = select_channels(BP,subject,task,schans,badchans);
[X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds);


 