%% Model envelope with state space model
%% TODO: 
% Problem with state space: no statistical testing
%% Data input
tsdim=6;
varmorder = 4;
nobs = 30000;
specrad = 0.98;
connect_matrix=cmatrix(tsdim);
fres=1024;
if ~exist('seed',   'var'), seed     = 0;    end % random seed (0 for unseeded)
if ~exist('svconly','var'), svconly  = true; end % only compute SVC for SS model order selection (faster)
if ~exist('plotm',  'var'), plotm    = 0;    end % plot mode (figure number offset, or Gnuplot terminal string)
%% Simulate data
[tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
%% Filter data 
[fs,fcut_low,fcut_high,filt_order, fir]=deal(500,90,110,128,1);
tsdata_filtered=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, fir);
%% Envelope extraction
envelope = tsdata2envelope(tsdata_filtered);
%% VAR modeling of the enveloppe
% VAR model order estimation

moregmode = 'LWR';   % VAR model estimation regression mode ('OLS' or 'LWR')
mosel     = 'LRT';   % model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
momax     = 50;      % maximum model order for model order selection
moact=varmorder;

%Calculate and plot VAR model order estimation criteria up to specified maximum model order.

ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(emvelope,momax,moregmode,[],[],[]);
ptoc;

% Select and report VAR model order.

%env_morder = input('morder = ')
env_morder = moselect(sprintf('VAR model order selection (max = %d)',momax), mosel,'ACT',moact,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
assert(env_morder > 0,'selected zero model order! GCs will all be zero!');
if env_morder >= momax, fprintf(2,'*** WARNING: selected maximum model order (may have been set too low)\n'); end
%% SS model order estimation of the envelope

ssmosel_env   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
pf_env = 2*env_morder;  % Bauer recommends 2 x VAR AIC model order
ssmo_env=tsdata2ssmo(envelope,ssmosel_env,pf_env,svconly,plotm)
%% SS model estimation of the envelope

% Estimate SS model order and model paramaters

[A_env,C_env,Kalman_gain_env,variance_env] = tsdata_to_ss(envelope,pf_env,ssmo_env);

% Report information on the estimated SS, and check for errors.

info_env = ss_info(A_env,C_env,Kalman_gain_env,variance_env);
assert(~info_env.error,'SS error(s) found - bailing out');
%% SS model order estimation of ts data
ssmosel_ts   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
pf_ts = 2*varmorder;  % Bauer recommends 2 x VAR AIC model order
ssmo_ts=tsdata2ssmo(tsdata,ssmosel_ts,pf_ts,svconly,plotm)

%% SS model estimation of tsdata

[A_ts,C_ts,Kalman_gain_ts,variance_ts] = tsdata_to_ss(tsdata,pf_ts,ssmo_ts);

% Report information on the estimated SS, and check for errors.

info_ts = ss_info(A_ts,C_ts,Kalman_gain_ts,variance_ts);
assert(~info_ts.error,'SS error(s) found - bailing out');
%% GC estimation of envelope time domain
% MVGC (time domain) statistical inference

testats    = 'dual';  % test statistic ('single', 'dual' or 'both')
alpha     = 0.05;    % significance level for Granger casuality significance test
mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')

% Estimated time-domain pairwise-conditional Granger causalities

ptic('*** ss_to_pwcgc... ');
pwcgc_envelope = ss_to_pwcgc(A_env,C_env,Kalman_gain_env,variance_env);
ptoc;
assert(~isbad(pwcgc_envelope,false),'GC estimation failed');

%% %% GC estimation of time series time domain
% MVGC (time domain) statistical inference

testats    = 'dual';  % test statistic ('single', 'dual' or 'both')
alpha     = 0.05;    % significance level for Granger casuality significance test
mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')

% Estimated time-domain pairwise-conditional Granger causalities

ptic('*** ss_to_pwcgc... ');
pwcgc_ts = ss_to_pwcgc(A_ts,C_ts,Kalman_gain_ts,variance_ts);
ptoc;
assert(~isbad(pwcgc_ts,false),'GC estimation failed');

%% Plot time-domain causal graph

plot_gc({pwcgc_ts,pwcgc_envelope},{'PWCGC (time_series)','PWCGC (envelope)'},[],[],plotm);

%% Granger causality estimation: frequency domain

%Envelope
ptic(sprintf('\n*** ss_to_spwcgc (at frequency resolution = %d)... ',fres));
spwcgc_env = ss_to_spwcgc(A_env,C_env,Kalman_gain_env,variance_env,fres);
ptoc;
assert(~isbad(spwcgc_env,false),'spectral GC estimation failed');

%time series

ptic(sprintf('*** ss_to_spwcgc (at frequency resolution = %d)... ',fres));
spwcgc_ts = ss_to_spwcgc(A_ts,C_ts,Kalman_gain_ts,variance_ts,fres);
ptoc;
assert(~isbad(spwcgc_ts,false),'spectral GC calculation failed');

% Get frequency vector according to the sampling rate.

freqs = sfreqs(fres,fs);

% Plot spectral causal graphs.

if isnumeric(plotm), plotm = plotm+1; end
plot_sgc({spwcgc_ts,spwcgc_env},freqs,'Spectral Granger causalities (blue = time series, red = envelope)',plotm);

%% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)
%Compute pwcgc of initial data integreted along specific frequency bands
band=[fcut_low, fcut_high];
pwcgc_ts_int = bandlimit(spwcgc_ts,3,fres,band); 
% Plot time-domain causal graph, p-values and significance.

pdata = {pwcgc_ts_int,pwcgc_envelope};
ptitle = {[num2str(fcut_low),'-',num2str(fcut_high),'Hz',' ', 'PWCGC (tsdata)'],'PWCGC (envelope)'}

% tgc_figure_path=[pwd,'\figures\Hilbert_envelope\'];
% tgc_fname=['tgc_',num2str(fcut_low),'-',num2str(fcut_high),'Hz_','env_morder',num2str(env_morder),'_','morder',num2str(env_morder),'_','tsdim', num2str(tsdim),'_','specrad',num2str(specrad),'.png'];
% tgc_fpath=[tgc_figure_path,tgc_fname];
plot_gc({pwcgc_ts_int,pwcgc_envelope},ptitle,[],[],plotm);
% saveas(gca,tgc_fpath);

% %Rescale spectral GC
% scale_factor=5;
% spwcgc_envelope_scaled=scale_factor*spwcgc_envelope;
% % Plot spectral causal graphs.
% sgc_plot_title=['Spectral Granger causalities (blue = tsdata, red = envelope',' scaling factor=',num2str(scale_factor),')']
% plot_sgc({spwcgc_tsdata,spwcgc_envelope_scaled},freqs,sgc_plot_title,[]);
% sgc_figure_path=[pwd,'\figures\Hilbert_envelope\'];
% sgc_fname=['sgc_',num2str(fcut_low),'-',num2str(fcut_high),'Hz_','env_morder',num2str(env_morder),'_','morder',num2str(varmorder),'_','tsdim', num2str(tsdim),'_','specrad',num2str(specrad),'.png'];
% sgc_fpath=[sgc_figure_path,sgc_fname];
% saveas(gcf,sgc_fpath);
