n = 8;
r = 10;
rhoa = 0.999;
g = 0.5;

fs = 250;
m = 50000;

pmax = 80;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[A,C,K] = iss_rand(n,r,rhoa);
V = corr_rand(n,g);
ss_info(A,C,K,V);

x = ss_to_tsdata(A,C,K,V,m);

F = ss_to_pwcgc(A,C,K,V)

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

Fx = ss_to_pwcgc(Ax,Cx,Kx,Vx)

%%%%%%%%%% Whiten %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = zeros(size(x));
for i = 1:n
	[aic,bic,hqc,lrt] = tsdata_to_varmo(x(i,:),pmax,'LWR',[],false,false,0);
	p = hqc;
	[a,v] = tsdata_to_var(x(i,:),p,'LWR');
	fprintf('p = %2d,  rho = %g\n',p,var_specrad(a));
	y(i,:) = genvma(-a,x(i,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = demean(y,true);
aicy = tsdata_to_varmo(y,pmax,'LWR',[],true,true,1,'');
pfy = 2*aicy;
fprintf('\npfy = %d\n\n',pfy);
[svcy,Ay,Cy,Ky,Vy] = tsdata_to_ss(y,pfy,[],[],1,'');
ss_info(Ay,Cy,Ky,Vy);

S = ss_to_cpsd(Ay,Cy,Ky,Vy,fres);
[Sya,Syc] = abspec(S);
gp_mplot({[f Sya],[f Syc]},[],[],'unset key\nset logs xy\nset grid','',[1 2]);

Fy = ss_to_pwcgc(Ay,Cy,Ky,Vy)
