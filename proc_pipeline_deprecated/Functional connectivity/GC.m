%% Granger Estimation
%% Preprocessed
tsdata=double(EEG.data); 
fres=2^11;
fs=EEG.srate;  
fc=1; %cutoff frequency
filt_order=1;
dsample=1;
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order); %filter and downsample
%% Select chans
pick_ROI=1:1:22;
pick_ROI=pick_ROI';
pick_chan=[];
[tsdata_ROI,pick_chan]=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx);
%% Slide window 
window_size=1000;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
tsdata_slided=tsdata2slided(tsdata_ROI, window_size,num_chan,tsdata_length);
ts_slided=squeeze(tsdata_slided(:,:,1)); %Pick a specific window
%% VAR modeling
momax=75;
moregmode='LWR';
regmode   = 'LWR'; 
num_window=size(tsdata_slided,3);
ptic('\n*** tsdata_to_varmo... ');
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(ts_out,momax,moregmode);
ptoc;
morder=input('morder=')
%% VAR estimation and spectral radius 
spectral_radius=zeros(num_window,1);
ptic('\n*** tsdata_to_var... ');
[A,V] = tsdata_to_var(ts_out,morder,regmode);
ptoc;
% Check for failed regression
assert(~isbad(A),'VAR estimation failed - bailing out');
info = var_info(A,V);
assert(~info.error,'VAR error(s) found - bailing out');
spectral_radius(i,1)=info.rho;
%% GC time estimation
tstats    = 'dual'; % test statistic ('single', 'dual' or 'both');
alpha=0.005;
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')
ptic('*** var_to_pwcgc... ');
[F,stats] = var_to_pwcgc(A,V,tstats,ts_slided,regmode);
ptoc;
assert(~isbad(F,false),'GC estimation failed');
maxF = 1.1*nanmax(F(:));
% Significance test (F- and likelihood ratio), adjusting for multiple hypotheses.
sigF  = significance(stats.(tstats).F.pval, alpha,mhtc);
sigLR = significance(stats.(tstats).LR.pval,alpha,mhtc);
% Plot
figure
subplot(2,2,1);
plot_pw(F,'PWCGC (estimated)',[],maxF);
subplot(2,2,2);
plot_pw(sigF,sprintf('F-test (%s-regression)\nSignificant at p = %g',tstats,alpha));
subplot(2,2,3);
plot_pw(sigLR,sprintf('LR test (%s-regression)\nSignificant at p = %g',tstats,alpha));
% %% Spectral GC
% ptic(sprintf('\n*** var_to_spwcgc (at frequency resolution = %d)... ',fres));
% f = var_to_spwcgc(A,V,fres);
% ptoc;
% assert(~isbad(f,false),'spectral GC estimation failed');
% % For comparison, we also calculate the actual pairwise-conditional spectral causalities
% ptic(sprintf('*** var_to_spwcgc (at frequency resolution = %d)... ',fres));
% ff = var_to_spwcgc(A,V,fres);
% ptoc;
% assert(~isbad(ff,false),'spectral GC calculation failed');
% % Get frequency vector according to the sampling rate.
% freqs = sfreqs(fres,fs);
% % Plot spectral causal graphs.
% figure
% plot_spw({ff,f},freqs,'Spectral Granger causalities (blue = actual, red = estimated)');
% %% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)
% 
% % Check that spectral causalities average (integrate) to time-domain
% % causalities. Note that this may occasionally fail if a certain condition
% % on the VAR parameters is not satisfied (see refs. [4,5]).
% 
% Fint = bandlimit(f,3); % integrate spectral MVGCs (frequency is dimension 3 of CPSD array
% fprintf('\n*** GC spectral integral check... ');
% rr = abs(F-Fint)./(1+abs(F)+abs(Fint)); % relative residuals
% mrr = max(rr(:));                       % maximum relative residual
% if mrr < 1e-5
%     fprintf('PASS: max relative residual = %.2e\n',mrr);
% else
%     fprintf(2,'FAIL: max relative residual = %.2e (too big!)\n',mrr);
% end