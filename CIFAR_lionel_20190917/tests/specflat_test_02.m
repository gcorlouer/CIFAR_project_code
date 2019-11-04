global cfmetadata; load(cfmetadata);

%schans = 41:50;

pmax = 60;

x    = downsample(X(schans,:),ds);
fs   = FS/ds;
nwin = 2*fs; % 2 seconds

[nschans,nobs] = size(x);

fres = 10000;
f = sfreqs(fres,fs);

x = demean(x,true);
aicx = tsdata_to_varmo(x,pmax,'LWR',[],true,true,1,'');
pfx = 2*aicx;
fprintf('\npfx = %d\n\n',pfx);
[svcx,Ax,Cx,Kx,Vx] = tsdata_to_ss(x,pfx,[],[],1,'');
ss_info(Ax,Cx,Kx,Vx);

S = ss_to_cpsd(Ax,Cx,Kx,Vx,fres);
[Sxa,Sxc] = abspec(S);
gp_mplot({[f Sxa],[f Sxc]},[],[],'unset key\nset logs xy\nset grid','',[1 2]);

% Whiten

y = zeros(size(x));
for i = 1:nschans
	[aic,bic,hqc,lrt] = tsdata_to_varmo(x(i,:),pmax,'LWR',[],false,false,0);
	p = hqc;
	[a,v] = tsdata_to_var(x(i,:),p,'LWR');
	fprintf('p = %2d,  rho = %g\n',p,var_specrad(a));
	y(i,:) = genvma(-a,x(i,:));
end

y = demean(y,true);
aicy = tsdata_to_varmo(y,pmax,'LWR',[],true,true,1,'');
pfy = 2*aicy;
fprintf('\npfy = %d\n\n',pfy);
[svcy,Ay,Cy,Ky,Vy] = tsdata_to_ss(y,pfy,[],[],1,'');
ss_info(Ay,Cy,Ky,Vy);

S = ss_to_cpsd(Ay,Cy,Ky,Vy,fres);
[Sya,Syc] = abspec(S);
gp_mplot({[f Sya],[f Syc]},[],[],'unset key\nset logs xy\nset grid','',[1 2]);
