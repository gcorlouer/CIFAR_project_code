global cfmetadata; load(cfmetadata);

%schans = 41:50;

pmax = 60;

x    = downsample(X(schans,:),ds);
fs   = FS/ds;
nwin = round(4*fs); % number of seconds

x = demean(x,true);

[nschans,nobs] = size(x);

[S,f,fres] = tsdata_to_cpsd(x,false,fs,nwin,[],[],false,true);
[Sa,Sc] = abspec(S);
gp_mplot({[f Sa],[f Sc]},[],[],'unset key\nset logs xy\nset grid','',[1 2]);

[aic,bic,hqc,lrt] = tsdata_to_varmo(x,pmax,'LWR',[],true,true,1,'');
[svc,A,C,K,V] = tsdata_to_ss(x,2*aic,[],[],1,'');
ss_info(A,C,K,V);

sfres = 10000;
f = sfreqs(sfres,fs);

SS = ss_to_cpsd(A,C,K,V,sfres);
[SSa,SSc] = abspec(SS);
gp_mplot({[f SSa],[f SSc]},[],[],'unset key\nset logs xy\nset grid','',[1 2]);
