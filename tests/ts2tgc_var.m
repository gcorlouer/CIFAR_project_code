% testats    = 'dual';  % test statistic ('single', 'dual' or 'both')
% alpha     = 0.05;    % significance level for Granger casuality significance test
% mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')
function [tgc_var,sigF,sigLR]=ts2tgc_var(tsdata,moregmode,mosel,regmode,testats, alpha, mhtc, plotm)
%Calculate and plot VAR model order estimation criteria up to specified maximum model order.
momax=50;
ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(tsdata,momax,moregmode,[],[],plotm,[]);
ptoc;
% Select and report VAR model order.

%morder = input('morder = ')
morder = moselect(sprintf('VAR model order selection (max = %d)',momax), mosel,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
assert(morder > 0,'selected zero model order! G Cs will all be zero!');
if morder >= momax, fprintf(2,'*** WARNING: selected maximum model order (may have been set too low)\n'); end
%% VAR model estimation (<mvgc_schema.html#3 |A2|>)
% Estimate VAR model of selected order from data.

ptic('\n*** tsdata_to_var... ');
[var_coef,corr_res] = tsdata_to_var(tsdata,morder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(var_coef),'VAR estimation failed - bailing out');
info = var_info(var_coef,corr_res);
assert(~info.error,'VAR error(s) found - bailing out');

%% MVGC (time domain) statistical inference

%Estimation

[tgc_var,stats] = var_to_pwcgc(var_coef,corr_res,testats,tsdata,regmode);
ptoc;
assert(~isbad(tgc_var,false),'GC estimation failed');

% Significance test (F- and likelihood ratio), adjusting for multiple hypotheses.

sigF  = significance(stats.(testats).F.pval, alpha,mhtc);
sigLR = significance(stats.(testats).LR.pval,alpha,mhtc);
