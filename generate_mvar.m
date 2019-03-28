%% Generate MVAR time series and store it in a file to be load with pytorch
%Also compute actual and estimated GC using mvgc toolbox in time domain to test GC using NN
%Define variables
fpath='/its/home/gc349/Causal_inf_convattention/data';
C=[1,1,0,0;0,1,0,1;0,1,1,0;1,0,0,1]; %connectivity matrix
csvwrite(fullfile(fpath,'connectivity_matrix.csv'),C);
n=4; %ts dimension
p=2; %model order
rho=0.5; % spectral radius
g=0.5; % g=-log(det(R)) where R is the correlation variance exp see corr_rand_exponent
w=0.5 ;% decay factor of var coefficients : why useful?
seed=0;
nobs=10000;   
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

%Simulate VAR data
A=var_rand(C,p,rho,w,[]); %Random_var coefficients with network C
V=corr_rand(n,g); %Random residuals correlation matrix
ptic('Simulating VAR model...');
tsdata=var_to_tsdata(A,V,nobs,ntrials,[],[]); %Simulated process
ptoc;
%Compute GC in time domain
%Estimated time-domain pairwise-conditional Granger causalities

ptic('*** var_to_pwcgc... ');
[F,stats] = var_to_pwcgc(A,V,tstats,tsdata,regmode);
ptoc;
assert(~isbad(F,false),'GC estimation failed');
maxF = 1.1*nanmax(F(:));
% Significance test (F- and likelihood ratio), adjusting for multiple hypotheses.

sigF  = significance(stats.(tstats).F.pval, alpha,mhtc);
sigLR = significance(stats.(tstats).LR.pval,alpha,mhtc);
    
% For comparison, we also calculate the actual pairwise-conditional causalities

ptic('*** var_to_pwcgc... ');
FF = var_to_pwcgc(A,V);
ptoc;
assert(~isbad(FF,false),'GC calculation failed');

%Plot time-domain causal graph, p-values and significance.

figure(2); clf;

% subplot(2,3,1);
% C = tnet; C(1:nvars+1:nvars*nvars) = NaN;
% plot_pw(C,'Connectivity');

subplot(2,2,1);
maxF = 1.1*max(nanmax(F(:),nanmax(FF(:))));
plot_pw(FF,'PWCGC (actual)',[],maxF);

subplot(2,2,2);
plot_pw(F,'PWCGC (estimated)',[],maxF);
    
subplot(2,2,3);
plot_pw(sigF,sprintf('F-test (%s-regression)\nSignificant at p = %g',tstats,alpha));

subplot(2,2,4);
plot_pw(sigLR,sprintf('LR test (%s-regression)\nSignificant at p = %g',tstats,alpha));

%Store time series in a file to be upload later on pytorch
%save('generated_var(num2str(n),num2str(p)).csv','X')
tsdata=tsdata';
csvwrite(fullfile(fpath,'generated_var.csv'),tsdata)