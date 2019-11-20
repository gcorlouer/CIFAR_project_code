%% Model envelope with state space model
%% TODO: 

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
%% Plot envelope
% chanum=1; %select channel to plot
% samlping_window=5000:7000;
% trange = samlping_window;
% plot_envelope(tsdata_filtered,envelope,trange, chanum, fs);
%% VAR modeling of the enveloppe
% VAR model order estimation

moregmode = 'LWR';   % VAR model estimation regression mode ('OLS' or 'LWR')
mosel     = 'LRT';   % model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
momax     = 50;      % maximum model order for model order selection
moact=varmorder;

%Calculate and plot VAR model order estimation criteria up to specified maximum model order.

ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(envelope,momax,moregmode,[],[],[]);
ptoc;

% Select and report VAR model order.

%env_morder = input('morder = ')
env_morder = moselect(sprintf('VAR model order selection (max = %d)',momax), mosel,'ACT',moact,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
assert(env_morder > 0,'selected zero model order! GCs will all be zero!');
if env_morder >= momax, fprintf(2,'*** WARNING: selected maximum model order (may have been set too low)\n'); end
%% SS model order estimation of the envelope
ssmosel_env   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)

pf_env = 2*env_morder; % Bauer recommends 2 x VAR AIC model order

if svconly  % SVC only: computationally much faster

	ptic('\n*** tsdata_to_sssvc... ');
	if isnumeric(plotm), plotm = plotm+1; end
	[ssmosvc_env_env,ssmomax_env] = tsdata_to_sssvc(envelope,pf_env,[],plotm);
	ptoc;

	% Select and report SS model order.

	ssmo_env = moselect(sprintf('SS model order selection (max = %d)',ssmomax_env),ssmosel_env,'SVC',ssmosvc_env_env);


else        % SVC + likelihood-based selection criteria + SVC: computational intensive

	ptic('\n*** tsdata_to_ssmo... ');
	if isnumeric(plotm), plotm = plotm+1; end
	[ssmoaic_env,ssmobic_env,ssmohqc_env,ssmosvc_env_env,ssmolrt_env,ssmomax_env] = tsdata_to_ssmo(envelope,pf_env,[],[],plotm);
	ptoc;

	% Select and report SS model order.

	ssmo_env = moselect(sprintf('SS model order selection (max = %d)',ssmomax_env),ssmosel_env,'ACT',ssmoact,'AIC',ssmoaic_env,'BIC',ssmobic_env,'HQC',ssmohqc_env,'SVC',ssmosvc_env_env,'LRT',ssmolrt_env);

end

assert(ssmo_env > 0,'selected zero model order! GCs will all be zero!');
if ssmo_env >= ssmomax_env, fprintf(2,'*** WARNING: selected SS maximum model order (may have been set too low)\n'); end

%% SS model estimation of the envelope

% Estimate SS model order and model paramaters

[A_env,C_env,Kalman_gain,Variance] = tsdata_to_ss(envelope,pf_env,ssmo_env);

% Report information on the estimated SS, and check for errors.

info = ss_info(A_env,C_env,Kalman_gain,Variance);
assert(~info.error,'SS error(s) found - bailing out');
%% GC estimation of envelope time domain
% MVGC (time domain) statistical inference

testats    = 'dual';  % test statistic ('single', 'dual' or 'both')
alpha     = 0.05;    % significance level for Granger casuality significance test
mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')

% Estimated time-domain pairwise-conditional Granger causalities

ptic('*** ss_to_pwcgc... ');
pwcgc_envelope = ss_to_pwcgc(A_env,C_env,Kalman_gain,Variance);
ptoc;
assert(~isbad(pwcgc_envelope,false),'GC estimation failed');

% NOTE: we don't have an analytic (asymptotic) distribution for the statistic, so no significance testing here!

% For comparison, we also calculate the actual pairwise-conditional causalities

ptic('*** ss_to_pwcgc... ');
FF = ss_to_pwcgc(AA,CC,KK,VV);
ptoc;
assert(~isbad(FF,false),'GC calculation failed');

% Plot time-domain causal graph

maxF = 1.1*max(nanmax(pwcgc_envelope(:),nanmax(FF(:))));
if isnumeric(plotm), plotm = plotm+1; end
plot_gc({FF,pwcgc_envelope},{'PWCGC (actual)','PWCGC (estimated)'},[],[maxF maxF],plotm);
%% Spectral GC
% Calculate spectral pairwise-conditional causalities resolution from VAR model
% parameters. If not specified, we set the frequency resolution to something
% sensible (based on the spectral radii of the VAR model - see var_info) - we also
% warn if the calculated resolution is very large, as this may cause problems.

ptic(sprintf('\n*** var_to_spwcgc (at frequency resolution = %d)... ',fres));
spwcgc_envelope = var_to_spwcgc(var_envelope,res_envelope,fres);
ptoc;
assert(~isbad(spwcgc_envelope,false),'spectral GC estimation failed');

% Compute spectral GC of simulated data

ptic(sprintf('*** var_to_spwcgc (at frequency resolution = %d)... ',fres));
spwcgc_tsdata = var_to_spwcgc(var_coef_ts,corr_res_ts,fres);
ptoc;
assert(~isbad(spwcgc_tsdata,false),'spectral GC calculation failed');

% Get frequency vector 
freqs = sfreqs(fres,fs);

%% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)
%Compute pwcgc of initial data integreted along specific frequency bands
band=[fcut_low, fcut_high];
pwcgc_ts_int = bandlimit(spwcgc_tsdata,3,fres,band); 
pwcgc_envelope_int = bandlimit(spwcgc_envelope,3,fres,band);
% Plot time-domain causal graph, p-values and significance.

pdata = {pwcgc_ts_int,pwcgc_envelope;sigF,sigLR};
ptitle = {[num2str(fcut_low),'-',num2str(fcut_high),'Hz',' ', 'PWCGC (tsdata)'],'PWCGC (HF envelope)'; sprintf('F-test (%s-regression)',testats),sprintf('LR test (%s-regression)',testats)};

tgc_figure_path=[pwd,'\figures\Hilbert_envelope\'];
tgc_fname=['tgc_',num2str(fcut_low),'-',num2str(fcut_high),'Hz_','env_morder',num2str(env_morder),'_','morder',num2str(env_morder),'_','tsdim', num2str(tsdim),'_','specrad',num2str(specrad),'.png'];
tgc_fpath=[tgc_figure_path,tgc_fname];
plot_gc(pdata,ptitle,[],[],[]);
saveas(gca,tgc_fpath);

%Rescale spectral GC
scale_factor=5;
spwcgc_envelope_scaled=scale_factor*spwcgc_envelope;
% Plot spectral causal graphs.
sgc_plot_title=['Spectral Granger causalities (blue = tsdata, red = envelope',' scaling factor=',num2str(scale_factor),')']
plot_sgc({spwcgc_tsdata,spwcgc_envelope_scaled},freqs,sgc_plot_title,[]);
sgc_figure_path=[pwd,'\figures\Hilbert_envelope\'];
sgc_fname=['sgc_',num2str(fcut_low),'-',num2str(fcut_high),'Hz_','env_morder',num2str(env_morder),'_','morder',num2str(varmorder),'_','tsdim', num2str(tsdim),'_','specrad',num2str(specrad),'.png'];
sgc_fpath=[sgc_figure_path,sgc_fname];
saveas(gcf,sgc_fpath);
