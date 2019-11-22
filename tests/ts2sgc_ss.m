%% Compute temporal Granger causality from time series via state space model
function [sgc,A,C,Kalman_gain,variance, ssmo]=ts2sgc_ss(tsdata, moregmode, mosel,fs,fres,plotm)
%% TODO
%% Parameters
% A,C,K,V are innovation form state space model parameters
% ssmo: state space model order
% Usually 
% moregmode = 'LWR';   % VAR model estimation regression mode ('OLS' or 'LWR')
% mosel     = 'LRT';   % model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
%% VAR modeling of tsdata

momax=50;

%Calculate and plot VAR model order estimation criteria up to specified maximum model order.

ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end
plotm=1;
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
plotm=plotm+1;
ssmo=tsdata2ssmo(tsdata,ssmosel,pf,svconly,plotm)
%% SS model estimation of tsdata

% Estimate SS model order and model paramaters

[A,C,Kalman_gain,variance] = tsdata_to_ss(tsdata,pf,ssmo);

% Report information on the estimated SS, and check for errors.

info = ss_info(A,C,Kalman_gain,variance);
assert(~info.error,'SS error(s) found - bailing out');
%% Granger causality spectral domain
if isempty(fres)
    fres = 2^nextpow2(max(info.acdec,infoo.acdec)); % alternatively, fres = 2^nextpow2(nobs);
	fprintf('\nUsing frequency resolution %d\n',fres);
end
if fres > 10000 % adjust to taste
	fprintf(2,'\nWARNING: large frequency resolution = %d - may cause computation time/memory usage problems\nAre you sure you wish to continue [y/n]? ',fres);
	istr = input(' ','s'); if isempty(istr) || ~strcmpi(istr,'y'); fprintf(2,'Aborting...\n'); return; end
end

ptic(sprintf('\n*** ss_to_spwcgc (at frequency resolution = %d)... ',fres));
sgc = ss_to_spwcgc(A,C,Kalman_gain,variance,fres);
ptoc;
assert(~isbad(sgc,false),'spectral GC estimation failed');

% Get frequency vector according to the sampling rate.

freqs = sfreqs(fres,fs);
