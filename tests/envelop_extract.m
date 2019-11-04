%% Enveloppe exctraction tests
%% TODO: 
%-Write function to plot envelope and time series 
%-Maybe sliding windows utilities
%-Test score to compare GC significance
%-Check cpsd plot, also spectral GC yields weird results with significant
%GC outside filtered frequency
%% Questions 
% Filtering iir or fir may not be minimum phase? So might also mess up GC
% 
%% Data
connect_matrix = [1 0 1 ;1 1 0; 1 0 1];
morder = 8;
moact = morder;
nobs = 10000;
specrad = 0.98;
chanum=1;
[tsdata,var_coef,corr_res]=var_sim(connect_matrix, morder, specrad, nobs);
sampling=1:1:nobs;
samlping_window=5000:7000;
plot(samlping_window,tsdata(chanum,samlping_window))
if ~exist('seed', 'var'), seed  = 0; end % random seed (0 for unseeded)
if ~exist('plotm','var'), plotm = 0; end % plot mode (figure number offset, or Gnuplot terminal string)

% MVGC (time domain) statistical inference

testats    = 'dual';  % test statistic ('single', 'dual' or 'both')
alpha     = 0.05;    % significance level for Granger casuality significance test
mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')
%% Filter data 
[fs,fcut_low,fcut_high,filt_order, iir]=deal(500,80,120,128,0);
tsdata_filtered=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, iir);
%% Envelope extraction
envelope = tsdata2envelope(tsdata_filtered);
%% Plot envelope 
sampling_range = samlping_window;
plot_envelope(tsdata_filtered,envelope,sampling_range, chanum, fs);
%% VAR modeling of the enveloppe
% VAR model order estimation
moregmode = 'LWR';   % VAR model estimation regression mode ('OLS' or 'LWR')
mosel     = 'LRT';   % model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
momax     = 50;      % maximum model order for model order selection
% VAR model parameter estimation
regmode   = 'OLS';   % VAR model estimation regression mode ('OLS' or 'LWR')

% Calculate and plot VAR model order estimation criteria up to specified maximum model order.
ptic('\n*** tsdata_to_varmo... ');
if isnumeric(plotm), plotm = plotm+1; end
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(envelope,momax,moregmode,[],[],plotm);
ptoc;

% Select and report VAR model order.
morder = input('morder = ')
% morder = moselect(sprintf('VAR model order selection (max = %d)',momax), mosel,'ACT',moact,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
% assert(morder > 0,'selected zero model order! GCs will all be zero!');
% if morder >= momax, fprintf(2,'*** WARNING: selected maximum model order (may have been set too low)\n'); end
%% VAR model estimation (<mvgc_schema.html#3 |A2|>)
% Estimate VAR model of selected order from data.

ptic('\n*** tsdata_to_var... ');
[estimated_var,estimated_res] = tsdata_to_var(envelope,morder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(estimated_var),'VAR estimation failed - bailing out');
info = var_info(estimated_var,estimated_res);
assert(~info.error,'VAR error(s) found - bailing out');
%% GC estimation of envelope
ptic('*** var_to_pwcgc... ');
[pwcgc,stats] = var_to_pwcgc(estimated_var,estimated_res,testats,envelope,regmode);
ptoc;
assert(~isbad(pwcgc,false),'GC estimation failed');

% Significance test (F- and likelihood ratio), adjusting for multiple hypotheses.

sigF  = significance(stats.(testats).F.pval, alpha,mhtc);
sigLR = significance(stats.(testats).LR.pval,alpha,mhtc);

% For comparison, we also calculate the actual pairwise-conditional causalities

ptic('*** var_to_pwcgc... ');
FF = var_to_pwcgc(var_coef,corr_res);
ptoc;
% assert(~isbad(FF,false),'GC calculation failed');

% Plot time-domain causal graph, p-values and significance.

maxF = 1.1*max(nanmax(pwcgc(:),nanmax(FF(:))));
pdata = {FF,pwcgc;sigF,sigLR};
ptitle = {'PWCGC (actual)','PWCGC (estimated)'; sprintf('F-test (%s-regression)',testats),sprintf('LR test (%s-regression)',testats)};
maxp = [maxF maxF;1 1];
if isnumeric(plotm), plotm = plotm+1; end
plot_gc(pdata,ptitle,[],maxp,plotm);
%% Spectral analysis
fs = 500;
[cpsd,f,fres] = tsdata_to_cpsd(tsdata,fs);
plot_cpsd(cpsd,[],fs)
%% Spectral GC
% Calculate spectral pairwise-conditional causalities resolution from VAR model
% parameters. If not specified, we set the frequency resolution to something
% sensible (based on the spectral radii of the VAR model - see var_info) - we also
% warn if the calculated resolution is very large, as this may cause problems.

ptic(sprintf('\n*** var_to_spwcgc (at frequency resolution = %d)... ',fres));
spwcgc = var_to_spwcgc(estimated_var,estimated_res,fres);
ptoc;
assert(~isbad(spwcgc,false),'spectral GC estimation failed');

% For comparison, we also calculate the actual pairwise-conditional spectral causalities

ptic(sprintf('*** var_to_spwcgc (at frequency resolution = %d)... ',fres));
actual_spwcgc = var_to_spwcgc(var_coef,corr_res,fres);
ptoc;
assert(~isbad(actual_spwcgc,false),'spectral GC calculation failed');

% Get frequency vector according to the sampling rate.

freqs = sfreqs(fres,fs);

% Plot spectral causal graphs.

if isnumeric(plotm), plotm = plotm+1; end
plot_sgc({actual_spwcgc,spwcgc},freqs,'Spectral Granger causalities (blue = actual, red = estimated)',plotm);
