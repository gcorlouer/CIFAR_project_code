%% Simulate MVAR time series and stores it in a csv file 
%Also compute actual and estimated GC using mvgc toolbox in time domain to test GC using NN
%Define variables
path2save='Causal_inf_convattention/data';
connect_matrix=[1,0,1;1,1,0;0,1,1]; 
csvwrite(fullfile(path2save,'connectivity_matrix.csv'),connect_matrix);
tsdim=3; 
morder=3; 
specrad=0.9;
g=0.5; % g=-log(det(R)) where R is the correlation variance exp see corr_rand_exponent
w=0.5 ;% decay factor of var coefficients : why useful?
seed=0;
nobs=100000;   
ntrials=1;
time=1:1:nobs;
% MVGC (time domain) statistical inference
alpha     = 0.05;   % significance level for Granger casuality significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')
tstats    = 'dual'; % test statistic ('single', 'dual' or 'both')

% VAR model parameter estimation
regmode   = 'LWR';  % VAR model estimation regression mode ('OLS' or 'LWR')
                    % LWR gives more accurate parameter estimates, but OLS
                    % estimates are maximum likelihood and therefore may
                    % play better with statistical inference.
%Seed random generator
rng_seed(seed);

%% Simulate VAR data
var_coef=var_rand(connect_matrix,morder,specrad,w,[]);
corr_res=corr_rand(tsdim,g); 
ptic('Simulating VAR model...');
tsdata=var_to_tsdata(var_coef,corr_res,nobs,ntrials,[],[]); %Simulated process
ptoc;
%% Compute GC in time domain
%Estimated time-domain pairwise-conditional Granger causalities

ptic('*** var_to_pwcgc... ');
[F,stats] = var_to_pwcgc(var_coef,corr_res,tstats,tsdata,regmode);
ptoc;
assert(~isbad(F,false),'GC estimation failed');
maxF = 1.1*nanmax(F(:));
% Significance test (F- and likelihood ratio), adjusting for multiple hypotheses.

sigF  = significance(stats.(tstats).F.pval, alpha,mhtc);
sigLR = significance(stats.(tstats).LR.pval,alpha,mhtc);
    
% For comparison, we also calculate the actual pairwise-conditional causalities

ptic('*** var_to_pwcgc... ');
FF = var_to_pwcgc(var_coef,corr_res);
ptoc;
assert(~isbad(FF,false),'GC calculation failed');

%Plot time-domain causal graph, p-values and significance.

figure(2); clf;

subplot(2,3,1);
C = tnet; C(1:nvars+1:nvars*nvars) = NaN;
plot_pw(C,'Connectivity');

subplot(2,2,1);
maxF = 1.1*max(nanmax(F(:),nanmax(FF(:))));
plot_pw(FF,'PWCGC (actual)',[],maxF);

subplot(2,2,2);
plot_pw(F,'PWCGC (estimated)',[],maxF);
    
subplot(2,2,3);
plot_pw(sigF,sprintf('F-test (%s-regression)\nSignificant at p = %g',tstats,alpha));

subplot(2,2,4);
plot_pw(sigLR,sprintf('LR test (%s-regression)\nSignificant at p = %g',tstats,alpha

%% Store time series in a file to be upload later on pytorch
%save('generated_var(num2str(n),num2str(p)).csv','X')
tsdata=tsdata'; 
csvwrite(fullfile(path2save,'generated_var.csv'),tsdata)