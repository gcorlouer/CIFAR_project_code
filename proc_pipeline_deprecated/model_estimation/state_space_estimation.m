%% State space modeling
n_chan=10;
momax=50;
X=EEG.data;
X([1,60],:)=[];%get rid of bad channels
X=X(1:n_chan,:);
varmosel  = 'AIC';  % VAR model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
varmomax  = 50 ; % maximum model order for VAR model order selection
moalpha   = 0.01;   % significance level for model order selection tests

% SS model parameter estimation

ssmo      = 'SVC';  % SS model order selection ('SVC', 'prompt' or supplied numerical value)

% MVGC (frequency domain)

fres      = [];     % spectral MVGC frequency resolution (empty for automatic calculation)
%% VAR model order estimation

% Calculate and plot VAR model order estimation criteria up to specified maximum model order.

figure(1); clf;
ptic('\n*** tsdata_to_varmo... ');
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(X,varmomax,'LWR',[],[],[],[],[]);
ptoc;

% Select and report VAR model order.

varmo = moselect(varmosel,'AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
assert(varmo > 0,'selected zero model order! GCs will all be zero!');
if varmo >= varmomax, fprintf(2,'*** WARNING: selected VAR maximum model order (may have been set too low)\n'); end
%% SS model estimation

% Estimate SS model order and model paramaters

figure(2); clf;
[ssmorder,A,C,K,V] = tsdata_to_ss(X,2*varmo,ssmo,true,[]);

% Check for failure:

assert(ssmorder > 0,'SS estimation error: %s',A); % if there's an error, reason returned in A

% Report information on the estimated SS, and check for errors.

info = ss_info(A,C,K,V);
assert(~info.error,'SS error(s) found - bailing out');
