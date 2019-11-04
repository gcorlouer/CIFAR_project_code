% clear; [X,fs] = test1_load_ECoG(1,'',2,1);

% schan = 30;
x = X(schan,:)';

fln = 180;

nsegs = 20;

m = length(x);
mseg = floor(m/nsegs);
m = nsegs*mseg;
x = x(1:m);

fprintf('\nsegments = %d\n',nsegs);
fprintf('seg len  = %d\n\n',mseg);
% t = (1:m)'/fs;
% T = t(end)

xx = reshape(x,mseg,nsegs);
yy = zeros(mseg,nsegs);

for k = 1:nsegs
	ffit = sinufitx(xx(:,k),fs,fln,false,1e-12);
	fprintf('segment %2d : ffit = %.3f\n',k,ffit);
	[yy(:,k),~,p,q] = sdetrendx(xx(:,k),fs,ffit);
end

y = reshape(yy,m,1);

[S,f,fres] = tsdata_to_cpsd([x y]',false,fs,8,[],[],true);

Sm = min(S(:));
Sx = max(S(:));
gpdat = [f S'];

gpterm = 'x11';
gpstem = fullfile(getenv('CFDATADIR'),'first_test','work','gp',[mfilename '_mstr']);
gp_write(gpstem,gpdat);
gp = gp_open(gpstem,gpterm,[],14);
fprintf(gp,'datfile = "%s.dat"\n\n',gpstem);
fprintf(gp,'set title "spectral power"\n');
fprintf(gp,'set xr[1:%g]\n',fs/2+10);
fprintf(gp,'set yr[%g:%g]\n',Sm,Sx);
fprintf(gp,'set xlabel "frequency"\n');
fprintf(gp,'set ylabel "power"\n');
fprintf(gp,'set logs xy\n');
fprintf(gp,'set grid\n');
fprintf(gp,'plot datfile u 1:2 w l ls 1 lw 2 t "raw", datfile u 1:3 w l ls 2 lw 2 t "sdt"\n');
gp_close(gp,gpstem,gpterm);
