function [newStat, oldStat] = inspectPreproc(tsdata, ts_detrend, timeStamp, varargin)

defaultVerb = 0;
defaultPford = 10;
defaultFignum = 1;
defaultFigsave   = false;

p = inputParser;

addRequired(p,'tsdata');
addRequired(p,'ts_detrend');
addRequired(p, 'timeStamp');
addParameter(p, 'verb', defaultVerb, @isscalar);
addParameter(p, 'fignum', defaultFignum);
addParameter(p, 'figsave', defaultFigsave, @islogical);
addParameter(p, 'pford', defaultPford, @isscalar);

parse(p, tsdata, ts_detrend, timeStamp, varargin{:});


oldStat.std  = std(     p.Results.tsdata,[],2);
oldStat.skew = skewness(p.Results.tsdata,0, 2);
oldStat.kurt = kurtosis(p.Results.tsdata,0, 2)-3;

newStat.std  = std(p.Results.ts_detrend,[],2);
newStat.skew = skewness(p.Results.ts_detrend,0, 2);
newStat.kurt = kurtosis(p.Results.ts_detrend,0, 2)-3;

% fprintf('\nold std. dev., skew, excess kurtosis :% 7.4f  % 7.4f  % 7.4f\n',  oldStat.std,oldskew,oldkurt);
% fprintf(  'new std. dev., skew, excess kurtosis :% 7.4f  % 7.4f  % 7.4f\n\n',newstd,newskew,newkurt);

end