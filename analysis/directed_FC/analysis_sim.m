%% Analysis simulated data

%% Import data

%% Filter data

% Highpass 1Hz
% locutoff = 1;
% hicutoff = 200;
% filtorder = 60;
% revfilt = [];
% usefft = []; 
% plotfreqz = [];
% firtype = [];
% causal = true;
% [EEG, com] = pop_eegfilt( EEG, locutoff, hicutoff);
%% Epoch data

wsize = [0 2];
wstep = 1;

outEEG = eeg_regepochs(EEG, 'recurrence', wstep, 'limits', wsize); 

Xepoch = outEEG.data;

%% Plot cpsd
fs = EEG.srate;
auto = true;
nchans = size(X,1);
logplt = false; 

[S,f,fres] = tsdata_to_cpsd(X,[],fs, [], [], [], true, []);

plot_autocpsd(S,f,fs,nchans, logplt)

%% VAR modeling

multitrial = true;

tic 
[VARmodel, VARmoest] = VARmodeling(Xepoch, 'momax', 40, 'mosel', 4, 'multitrial', multitrial);
toc

%% SS modeling

tic
[SSmodel, moest] = SSmodeling(Xepoch, 'mosel', 4, 'multitrial', multitrial);
toc


%% GC estimation

regmode = 'LWR';
tstats = 'dual';
alpha = 0.05;
mhtc = 'FDR';

ssF = ss_to_pwcgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V);

[varF, varStats] = var_to_pwcgc(VARmodel.A,VARmodel.V,tstats, Xepoch,regmode);

% Significance test (F- and likelihood ratio), adjusting for multiple hypotheses.

sigF  = significance(varStats.(tstats).F.pval, alpha, mhtc);
sigLR = significance(varStats.(tstats).LR.pval,alpha, mhtc);

pdata = {varF, ssF; sigF,sigLR};

ptitle = {'PWCGC (var)','PWCGC (SS)'; ... 
    sprintf('F-test (%s-regression)',tstats), sprintf('LR test (%s-regression)',tstats)};
plot_gc(pdata, ptitle,[],[],[]);
