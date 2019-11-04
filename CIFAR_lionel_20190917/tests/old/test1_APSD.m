load(getenv('METADATA'));

% Supply drugnum

if ~exist('rmln',     'var'), rmln     = 'SDT';  end
if ~exist('ds',       'var'), ds       = 1;      end
if ~exist('fres',     'var'), fres     = 4096;   end
if ~exist('mtaper',   'var'), mtaper   = false;  end
if ~exist('winfac',   'var'), winfac   = 16;     end
if ~exist('tapers',   'var'), tapers   = [3 5];  end
if ~exist('noverlap', 'var'), noverlap = [];     end
if ~exist('dmflag',   'var'), dmflag   = 0;      end % don't demean or normalise

if mtaper
	mstr   = 'mtaper';
	sparms = tapers;
else
	mstr   = 'pwelch';
	sparms = noverlap;
end

fprintf('\nrmln    = %s\n',  rmln);
fprintf('ds      = %d\n',  ds);
fprintf('method  = %s\n',  mstr);
fprintf('winfac  = %g\n',  winfac);
fprintf('fres    = %d\n\n',fres);

[X,fs] = test1_load_ECoG(ds,rmln,dmflag,true);

[S,f,fres] = tsdata_to_cpsd(X,mtaper,fs,winfac,sparms,fres,true);

clear X;

ffname = fullfile(getenv('CFDATADIR'),'first_test','ANAL',[ 'APSD_' rmln '_dmflag_' num2str(dmflag) '_fs_' num2str(fs) '_' mstr '_winfac_' num2str(winfac) '_fres_' num2str(fres) '.mat']);
fprintf('Saving data file: ''%s'' ... ',ffname);
save(ffname);
fprintf('done\n');
