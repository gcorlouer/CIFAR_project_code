%% Compute temporal Granger causality from time series via state space model
function [tgc,A,C,Kalman_gain,variance, ssmo]=ts2tgc_ss(tsdata, moregmode, mosel, momax,plotm)
%% TODO
%% Parameters
% A,C,K,V are innovation form state space model parameters
% ssmo: state space model order
% Usually 
% moregmode = 'LWR';   % VAR model estimation regression mode ('OLS' or 'LWR')
% mosel     = 'LRT';   % model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
%% VAR modeling of tsdata

if nargin < 4 
    momax=50;
end

%Calculate and plot VAR model order estimation criteria up to specified maximum model order.

ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end

[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(tsdata,momax,moregmode,[],[],plotm,[]);
ptoc;

% Select and report VAR model order.

%morder = input('morder = ')
morder = moselect(sprintf('VAR model order selection (max = %d)',momax), mosel,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
assert(morder > 0,'selected zero model order! GCs will all be zero!');
if morder >= momax, fprintf(2,'*** WARNING: selected maximum model order (may have been set too low)\n'); end
%% SS model order estimation of tsdata

ssmosel   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
pf = 2*morder;  % Bauer recommends 2 x VAR AIC model order
svconly=1;
ssmo=tsdata2ssmo(tsdata,ssmosel,pf,svconly,plotm)
%% SS model estimation of tsdata

% Estimate SS model order and model paramaters

[A,C,Kalman_gain,variance] = tsdata_to_ss(tsdata,pf,ssmo);

% Report information on the estimated SS, and check for errors.

info = ss_info(A,C,Kalman_gain,variance);
assert(~info.error,'SS error(s) found - bailing out');
%% Granger causality calculation: time domain

% Estimated time-domain pairwise-conditional Granger causalities

ptic('*** ss_to_pwcgc... ');
tgc = ss_to_pwcgc(A,C,Kalman_gain,variance);
ptoc;
assert(~isbad(tgc,false),'GC estimation failed');
