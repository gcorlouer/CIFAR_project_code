function [rhoa,rhob,mii]= ss_mostat(X,ts,mosvc,pf,nwin,nsobs,nwobs,tsw)

rhoa = zeros(nwin,1);
rhob = zeros(nwin,1);
mii  = zeros(nwin,1);

for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[A,C,K,V] = tsdata_to_ss(W,pf(w),mosvc(w));
	info = ss_info(A,C,K,V,0);
	rhoa(w) = info.rhoA;
	rhob(w) = info.rhoB;
	mii(w)  = info.mii;
	fprintf('AR rho = %6.4f, MA rho = %6.4f, mii = %6.4f\n',rhoa(w),rhob(w),mii(w));
end

%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

yyaxis left
plot(tsw,-log(1-[rhoa rhob]));
ylabel('-log(1-specrad)');
yyaxis right
plot(tsw,mii);
xlim([ts(1) ts(end)]);
ylabel('residuals multi-information');
xlabel('time (secs)');
legend({'AR','MA','MII'});