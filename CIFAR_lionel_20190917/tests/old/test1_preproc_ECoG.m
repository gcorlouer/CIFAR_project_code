load(getenv('METADATA'));

ffname = fullfile(getenv('CFDATADIR'),'first_test','ECoG','testdata_raw.mat');
assert(exist(ffname,'file') == 2,'\nFile ''%s'' not found',ffname);
fprintf('loading data file: ''%s'' ... ',ffname);
load(ffname);
fprintf('done\n\n');

[n,m] = size(X);

% Remove line noise

switch rmln
case 'SDT'
    fprintf('Removing line noise (SDT)\n');
	for i = 1:n
		fprintf('\tchannel %3d of %3d\n',i,n);
		x = X(i,:)';
		fln   = lnfreq;
		nsegs = 10;
		x = lnsdt(x,FS,fln,nsegs);
		fln   = 2*lnfreq;
		nsegs = 5;
		x = lnsdt(x,FS,fln,nsegs);
		fln   = 3*lnfreq;
		nsegs = 20;
		x = lnsdt(x,FS,fln,nsegs);
		fln   = 4*lnfreq;
		nsegs = 2;
		x = lnsdt(x,FS,fln,nsegs);
		X(i,:) = x';
	end
end

ffname = fullfile(getenv('CFDATADIR'),'first_test','ECoG',['testdata_' rmln '.mat']);
fprintf('Saving data file: ''%s'' ... ',ffname);
save(ffname,'X','FS','t','rmln');
fprintf('done\n');

function y = lnsdt(x,fs,fln,nsegs)

	M = length(x);
	mseg = floor(M/nsegs);
	m = nsegs*mseg;

	xx = reshape(x(M-m+1:M),mseg,nsegs); % last nsegs segments
	yy = zeros(mseg,nsegs);

	for k = 1:nsegs
		ffit = sinufitx(xx(:,k),fs,fln,false,1e-12);
		yy(:,k) = sdetrendx(xx(:,k),fs,ffit);
	end

	x1 = x(1:mseg);                      % first segment
	ffit = sinufitx(x1,fs,fln,false,1e-12);
	y1 = sdetrendx(x1,fs,ffit);

	y = zeros(size(x));
	y(M-m+1:M) = reshape(yy,m,1);        % last nsegs segments
	y(1:mseg) = y1;                      % first segment

	end
