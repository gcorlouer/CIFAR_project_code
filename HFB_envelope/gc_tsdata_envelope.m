%% Enveloppe exctraction tests
%% TODO: 
%-Test score for GC comparison
%-Sliding windows utilities
%-Extract other frequencies and look GC between different HFB
%-create a function that output GC plots
%add title to plots
% TO save figure check you have the right pwd (use cd otherwise)
%% Data input
tsdim=4;
varmorder = 4;
nobs = 30000;
specrad = 0.98;
connect_matrix=cmatrix(tsdim);
fres=1024;
if ~exist('seed', 'var'), seed  = 0; end % random seed (0 for unseeded)
%if ~exist('plotm','var'), plotm = 0; end % plot mode (figure number offset, or Gnuplot terminal string)
%% Simulate data
[tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
%% Filter data 
iir=1;
[fs,fcut_low,fcut_high,filt_order, fir]=deal(500,90,110,128,0);
tsdata_filtered=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, iir);
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
% VAR model parameter estimation
regmode   = 'OLS';   % VAR model estimation regression mode ('OLS' or 'LWR')

%Calculate and plot VAR model order estimation criteria up to specified maximum model order.

ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(envelope,momax,moregmode,[],[],[]);
ptoc;

% Select and report VAR model order.

%env_morder = input('morder = ')
env_morder = moselect(sprintf('VAR model order selection (max = %d)',momax), mosel,'ACT',moact,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
% assert(morder > 0,'selected zero model order! GCs will all be zero!');
% if morder >= momax, fprintf(2,'*** WARNING: selected maximum model order (may have been set too low)\n'); end
%% VAR model estimation (<mvgc_schema.html#3 |A2|>)
% Estimate VAR model of selected order from data.

ptic('\n*** tsdata_to_var... ');
[var_envelope,res_envelope] = tsdata_to_var(envelope,env_morder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(var_envelope),'VAR estimation failed - bailing out');
info = var_info(var_envelope,res_envelope);
assert(~info.error,'VAR error(s) found - bailing out');
%% GC estimation of envelope
% MVGC (time domain) statistical inference

testats    = 'dual';  % test statistic ('single', 'dual' or 'both')
alpha     = 0.05;    % significance level for Granger casuality significance test
mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')
ptic('*** var_to_pwcgc... ');

%Estimation

[pwcgc_envelope,stats] = var_to_pwcgc(var_envelope,res_envelope,testats,envelope,regmode);
ptoc;
assert(~isbad(pwcgc_envelope,false),'GC estimation failed');

% Significance test (F- and likelihood ratio), adjusting for multiple hypotheses.

sigF  = significance(stats.(testats).F.pval, alpha,mhtc);
sigLR = significance(stats.(testats).LR.pval,alpha,mhtc);

% Calculate the actual pairwise-conditional causalities of data

ptic('*** var_to_pwcgc... ');
pwcgc_tsdata = var_to_pwcgc(var_coef_ts,corr_res_ts);
ptoc;
% assert(~isbad(FF,false),'GC calculation failed');

% Plot time-domain causal graph, p-values and significance.

maxpwcgc = 1.1*max(nanmax(pwcgc_envelope(:),nanmax(pwcgc_tsdata(:))));
pdata = {pwcgc_tsdata,pwcgc_envelope;sigF,sigLR};
ptitle = {'PWCGC (tsdata)','PWCGC (HF envelope)'; sprintf('F-test (%s-regression)',testats),sprintf('LR test (%s-regression)',testats)};
maxp = [maxpwcgc maxpwcgc;1 1];%???? 
%if isnumeric(plotm), plotm = plotm+1; end
plot_gc(pdata,ptitle,[],[],[]);
%% Spectral analysis
fs = 500;
[cpsd_tsdata,f,fres] = tsdata_to_cpsd(tsdata,false,fs,[],[],fres,true,false);
apsd_tsdata_figure_path=[pwd,'\figures\Hilbert_envelope\'];
apsd_tsdata_fname=['auto_cpsd_tsdata',num2str(varmorder),'_','tsdim', num2str(tsdim),'_','specrad',num2str(specrad),'.png'];
apsd_tsdata_fpath=[apsd_tsdata_figure_path,apsd_tsdata_fname];
figure
plot_autocpsd(cpsd_tsdata,f,fs,tsdim);
saveas(gcf,apsd_tsdata_fpath);
[cpsd_envelope,f,fres] = tsdata_to_cpsd(envelope,false,fs,[],[],fres,true,false);
apsd_envelope_figure_path=[pwd,'\figures\Hilbert_envelope\'];
apsd_envelope_fname=['auto_cpsd_envelope',num2str(env_morder),'_','tsdim', num2str(tsdim),'_','specrad',num2str(specrad),'.png'];
apsd_envelope_fpath=[apsd_envelope_figure_path,apsd_envelope_fname];
figure
plot_autocpsd(cpsd_envelope,f,fs,tsdim);
saveas(gcf,apsd_envelope_fpath);
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

% %% Plot finer spectral graph
% k=0;
% figure
% for i=1:tsdim
%     for j=1:tsdim
%         k=k+1;
%         subplot(2*tsdim,tsdim,k)
%         plot(freqs, squeeze(spwcgc_envelope(i,j,:)))
%         subplot(2*tsdim,tsdim,k+1)
%         plot(freqs, squeeze(spwcgc_tsdata(i,j,:)))
%     end
% end