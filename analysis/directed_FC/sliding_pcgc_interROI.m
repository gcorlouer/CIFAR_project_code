%% Run analysis on ROI

%% Parameters

if ~exist('schans1',   'var'), schans1   = -6;        end % selected channels (empty for all good, negative for ROI number)
if ~exist('schans2',   'var'), schans2   = -10;       end % selected channels (empty for all good, negative for ROI number)
if ~exist('tseg',      'var'),       tseg           = [10 50];                                          end % start/end times (empty for entire time series)
if ~exist('ds',        'var'),       ds             = 1;                                                end % downsample factor
if ~exist('bigfile',   'var'),       bigfile        = false;                                            end % data file too large to read into memory
if ~exist('wind',      'var'),       wind           = [5 1];                                            end % window width and slide time (secs)
if ~exist('tstamp',    'var'),       tstamp         = 'mid';                                            end % window time stamp: 'start', 'mid', or 'end'
if ~exist('fres',      'var'),       fres           = 1024;                                             end % number of freq bins
if ~exist('subject',   'var'),       subject        = 'AnRa';                                           end %
if ~exist('task',   'var'),          task           = 'rest_baseline_1';                                end % 
if ~exist('BP',        'var'),       BP             = 1;                                                end % BP=-1 for simulated data
if ~exist('ppdir',     'var'),       ppdir          = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; end %preproc directory
if ~exist('fig_path_tail',   'var'), fig_path_tail  = '/figures/stationarity/ssmodeling/';              end %path 2 save figure
if ~exist('iband',   'var'),         iband          = 2;                                                end
if ~exist('band_low',   'var'),      band_low       = 60;                                               end
if ~exist('band_size',   'var'),     band_size      = 20;                                               end
if ~exist('nband',   'var'),         nband          =   5;                                              end
if ~exist('filt_order',   'var'),    filt_order     = 138;                                              end
if ~exist('nobs',   'var'),          nobs           = 100000;                                           end
if ~exist('fs',   'var'),            fs             = 500 ;                                             end
if ~exist('g',   'var'),             g              = [] ;                                              end
if ~exist('w',   'var'),             w              = [] ;                                              end
if ~exist('ntrials',   'var'),       ntrials        = 1 ;                                               end
if ~exist('momax',   'var'),         momax          = 10 ;                                              end
if ~exist('momax',   'var'),         mosel          = 1;                                                end
if ~exist('moregmode',   'var'),     moregmode      = 'LWR' ;                                           end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import data
[chans1,chanstr1] = select_channels(BP,subject,task,schans1); % Drop bad channels
[chans2,chanstr2] = select_channels(BP,subject,task,schans2);

[EEG,filepath,filename] = get_EEG_info(BP,subject,task);
goodROI_select; %add good ROI to EEG struct (to be implemented in the SUMA file later)
[chans,chanstr,~,ogchans] = select_channels(BP,subject,task,[chans1 chans2]);
[X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds); % [chans ogchans] for all ROI and chans otherwise

xchans1 = 1:length(chans1);                  % ROI 1 in X
xchans2 = length(chans1)+(1:length(chans2)); % ROI 2 in X
group = num2cell([xchans1 , xchans2],1);

%% Extract envelope at a given frequency band

[envelope_band,band] = tsdata2HFB(X,fs,band_low,band_size,nband,filt_order);
envelope_fband       = envelope_band(:,:,iband);

%% Slice state space model on envelope

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp);

[nchans,nobs] = size(X);
g = size(group,2);
MVGC = zeros(nwin,g,g);

for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window\\
	[moaic,~,~,~] = tsdata_to_varmo(X,momax,moregmode);
    morder = moaic;
    pf = 2*morder;  % Bauer recommends 2 x VAR AIC model order
    [mosvc,ssmomax] = tsdata_to_ssmo(X,pf);
    [A,C,K,V] = tsdata_to_ss(X,pf,mosvc);
    MVGC(w,:,:) = ss_to_gwcgc(A,C,K,V,group);
	% MVGC(w) = ss_to_mvgc(A,C,K,V,xchans1,xchans2);
	fprintf('GC = % 6.4f\n',MVGC(w,:,:));
end

%% Inter ROI Granger causality analysis

%% Plot 
mean_MVGC = mean(MVGC,1);
