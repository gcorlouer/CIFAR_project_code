function [sgc_var,freqs]=ts2sgc_var(tsdata,moregmode,mosel,regmode,fres, fs, plotm)
%% TODO
%%
%Calculate and plot VAR model order estimation criteria up to specified maximum model order.
momax=50;
ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(tsdata,momax,moregmode,[],[],plotm,[]);
ptoc;
% Select and report VAR model order.

%morder = input('morder = ')
morder = moselect(sprintf('VAR model order selection (max = %d)',momax), mosel,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
assert(morder > 0,'selected zero model order! GCs will all be zero!');
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
%% Granger causality estimation: frequency domain  (<mvgc_schema.html#3 |A14|>)
if isempty(fres)
    fres = 2^nextpow2(max(info.acdec,infoo.acdec)); % alternatively, fres = 2^nextpow2(nobs);
	fprintf('\nUsing frequency resolution %d\n',fres);
end
if fres > 10000 % adjust to taste
	fprintf(2,'\nWARNING: large frequency resolution = %d - may cause computation time/memory usage problems\nAre you sure you wish to continue [y/n]? ',fres);
	istr = input(' ','s'); if isempty(istr) || ~strcmpi(istr,'y'); fprintf(2,'Aborting...\n'); return; end
end

ptic(sprintf('\n*** var_to_spwcgc (at frequency resolution = %d)... ',fres));
sgc_var = var_to_spwcgc(var_coef,corr_res,fres);
ptoc;
assert(~isbad(sgc_var,false),'spectral GC estimation failed');

% Get frequency vector according to the sampling rate.

freqs = sfreqs(fres,fs);
