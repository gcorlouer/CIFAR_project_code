function inspectDetrend(X,ts,varargin)

defaultFs = 500;
defaultLnfreq = 60 ;
defaultWind = [5 1];
defaultTstamp = 'mid';
defaultVerb = 0;
defaultPford = 10;
defaultFignum = 1;
defaultFigsave   = false;

p = inputParser;

addRequired(p,'X');
addRequired(p,'ts');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'lnfreq', defaultLnfreq, @isscalar);
addParameter(p, 'wind', defaultWind, @isvector);
addParameter(p, 'tstamp', defaultTstamp, @isscalar);
addParameter(p, 'verb', defaultVerb, @isscalar);
addParameter(p, 'pford', defaultPford, @islogical);
addParameter(p, 'fignum', defaultFignum);
addParameter(p, 'figsave', defaultFigsave, @islogical);

parse(p, X, ts, varargin{:});

oldstd  = std(     p.Results.X,[],2);
oldskew = skewness(p.Results.X,0, 2);
oldkurt = kurtosis(p.Results.X,0, 2)-3;

[Y,wflag,Z] = pfdetrend(p.Results.X,p.Results.fs,p.Results.pford);
if wflag, fprintf(2,'WARNING: ''polyfit'' unreliable\n'); end

newstd  = std(     Y,[],2);
newskew = skewness(Y,0, 2);
newkurt = kurtosis(Y,0, 2)-3;

fprintf('\nold std. dev., skew, excess kurtosis :% 7.4f  % 7.4f  % 7.4f\n',  oldstd,oldskew,oldkurt);
fprintf(  'new std. dev., skew, excess kurtosis :% 7.4f  % 7.4f  % 7.4f\n\n',newstd,newskew,newkurt);

if ~isempty(p.Results.fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(p.Results.ts',[X;Y;Z]');
	xlabel('time (secs)');
	ylabel('ECoG');
	xlim([p.Results.ts(1) p.Results.ts(end)]);
	legend({'original','detrended',sprintf('trend (order = %d)',p.Results.pford)},'Location', 'northeastoutside','Interpreter','none');

end