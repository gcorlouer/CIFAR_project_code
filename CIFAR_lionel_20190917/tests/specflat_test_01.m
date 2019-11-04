global cfmetadata; load(cfmetadata);

%schans = 41:50;


pmax = 60;

x    = downsample(X(schans,:),ds);
fs   = FS/ds;
nwin = 2*fs; % 2 seconds

[nschans,nobs] = size(x);

x = demean(x,true);
[S,f,fres] = tsdata_to_cpsd(x,false,fs,nwin,[],[],false,true);
[Sxa,Sxc] = abspec(S);

% gp_qplot(f,[Sxa Sxc],[],'unset key\nset logs xy\nset grid');
gp_mplot({[f Sxa],[f Sxc]},[],[],'unset key\nset logs xy\nset grid','',[1 2]);

[aic,bic,hqc,lrt] = tsdata_to_varmo(x,pmax,'LWR',[],true,true,1,'');

px = hqc;
[Ax,Vx] = tsdata_to_var(x,px,'LWR');
fprintf('\npx = %2d,  rhox = %g\n\n',px,var_specrad(Ax));

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
[S,f,fres] = tsdata_to_cpsd(y,false,fs,nwin,[],[],false,true);
[Sya,Syc] = abspec(S);

% gp_qplot(f,[Sya Syc],[],'unset key\nset logs xy\nset grid');
gp_mplot({[f Sya],[f Syc]},[],[],'unset key\nset logs xy\nset grid','',[1 2]);

[aic,bic,hqc,lrt] = tsdata_to_varmo(y,pmax,'LWR',[],true,true,1,'');

py = hqc;
[Ay,Vy] = tsdata_to_var(y,py,'LWR');
fprintf('\npy = %2d,  rhoy = %g\n\n',py,var_specrad(Ay));
