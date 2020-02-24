%% State space model morder from time series input
%% Input arguments
%svconly: logical, decide wether to use svc or not
%ssmosel: Model order selection criterion
%tsdata: input data
%pf?
%plotm: plotin utility for gnuplot, plotm = []      - don't plot

function ssmo=tsdata2ssmo(tsdata,ssmosel,pf,svconly,plotm)

%ssmosel   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
%pf = 2*env_morder; % Bauer recommends 2 x VAR AIC model order

if svconly  % SVC only: computationally much faster

	ptic('\n*** tsdata_to_sssvc... ');
	[ssmosvc,ssmomax] = tsdata_to_sssvc(tsdata,pf,[],plotm);
	ptoc;

	% Select and report SS model order.

	ssmo = moselect(sprintf('SS model order selection (max = %d)',ssmomax),ssmosel,'SVC',ssmosvc);
 

else        % SVC + likelihood-based selection criteria + SVC: computational intensive

	ptic('\n*** tsdata_to_ssmo... ');
	[ssmoaic,ssmobic,ssmohqc,ssmosvc,ssmolrt,ssmomax] = tsdata_to_ssmo(tsdata,pf);
	ptoc;

	% Select and report SS model order.

	ssmo = moselect(sprintf('SS model order selection (max = %d)',ssmomax),ssmosel,'ACT',ssmoaic,'BIC',ssmobic,'HQC',ssmohqc,'SVC',ssmosvc,'LRT',ssmolrt);

end

assert(ssmo > 0,'selected zero model order! GCs will all be zero!');
if ssmo >= ssmomax, fprintf(2,'*** WARNING: selected SS maximum model order (may have been set too low)\n'); end