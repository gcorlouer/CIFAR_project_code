function [X,fs] = test1_load_ECoG(ds,rmln,dmflag,verb)

load(getenv('METADATA'));

ffname = fullfile(getenv('CFDATADIR'),'first_test','ECoG',['testdata_' rmln '.mat']);
assert(exist(ffname,'file') == 2,'\nFile ''%s'' not found',ffname);
if verb, fprintf('loading data file: ''%s'' ... ',ffname); end
load(ffname);
if verb, fprintf('done'); end

% Downsample

if ds > 1
    if verb, fprintf(' : downsampling x %d',ds); end
    X = downsample(X,ds);
end

fs = FS/ds;

ldetrend = dmflag < -eps;
if ldetrend, dmflag = -dmflag; end

if ldetrend
	fprintf(' : detrending');
	X = detrend(X')';
end

if dmflag > eps
	normit = dmflag > 1+eps;
	if verb
		if normit
			fprintf(' : demeaning and normalising');
		else
			fprintf(' : demeaning');
		end
	end
	X = demean(X,normit);
end

if verb, fprintf('\n'); end
