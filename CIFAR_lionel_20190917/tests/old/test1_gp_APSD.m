load(getenv('METADATA'));

% Defaults

if ~exist('rmln',     'var'), rmln     = 'SDT';  end
if ~exist('fs',       'var'), fs       = 500;    end
if ~exist('fres',     'var'), fres     = 4096;   end
if ~exist('mtaper',   'var'), mtaper   = false;  end
if ~exist('winfac',   'var'), winfac   = 16;     end
if ~exist('tapers',   'var'), tapers   = [3 5];  end
if ~exist('noverlap', 'var'), noverlap = [];     end
if ~exist('dmflag',   'var'), dmflag   = 0;      end % don't demean or normalise
if ~exist('schans',   'var'), schans   = [];     end
if ~exist('gpterm',   'var'), gpterm   = 'png';  end

if mtaper
	mstr   = 'mtaper';
	sparms = tapers;
else
	mstr   = 'pwelch';
	sparms = noverlap;
end

fprintf('\nrmln    = %s\n',  rmln);
fprintf('fs      = %g\n',  fs);
fprintf('method  = %s\n',  mstr);
fprintf('winfac  = %g\n',  winfac);
fprintf('fres    = %d\n\n',fres);

ffname = fullfile(getenv('CFDATADIR'),'first_test','ANAL',[ 'APSD_' rmln '_dmflag_' num2str(dmflag) '_fs_' num2str(fs) '_' mstr '_winfac_' num2str(winfac) '_fres_' num2str(fres) '.mat']);
assert(exist(ffname,'file') == 2,'\nFile ''%s'' not found',ffname);
fprintf('loading data file: ''%s'' ... ',ffname);
load(ffname);
fprintf('done\n');

if isempty(schans)
	schans = 2:size(S,1);
end
S = S(schans,:);
nschans = size(S,1);

Smax = max(S(:));
Smin = min(S(:));

gpstem = fullfile(getenv('CFDATADIR'),'first_test','work','gp',[mfilename '_mstr']);

gp_write(gpstem,[f S']);

gp = gp_open(gpstem,gpterm,[],14);
fprintf(gp,'datfile = "%s.dat"\n\n',gpstem);
fprintf(gp,'set title "spectral power"\n');
fprintf(gp,'set xr[1:%g]\n',fs/2+10);
fprintf(gp,'set yr[%g:%g]\n',Smin,Smax);
fprintf(gp,'set xtics (%s)\n',make_fband_tics(fbands));
fprintf(gp,'set logs xy\n');
for k = 1:6
	fk = fbands{k}{2}(2);
	fprintf(gp,'set arrow from first %g,graph 0 to first %g,graph 1 nohead\n',fk,fk);
end
fprintf(gp,'plot \\\n');
for i = 1:nschans
	fprintf(gp,'datfile u 1:%d w l ls 1 not, \\\n',i+1);
end
fprintf(gp,'NaN not\n');
gp_close(gp,gpstem,gpterm);
