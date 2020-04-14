function [SSmodel, moest] = multiTrial_SSmodeling(X, varargin)

defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'LWR';
defaultPlotm = 1;

p = inputParser;

addRequired(p,'X');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode, @vector);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);  

parse(p, X, varargin{:});

[nchan, nobs, ntrials] = size(p.Results.X);

% VAR model estimation
[moest(1), moest(2),moest(3),moest(4)] = ... 
    tsdata_to_varmo(p.Results.X, p.Results.momax,p.Results.moregmode);
% SSm svc estimation
SSmodel.pf = 2*moest(p.Results.mosel); %;  % Bauer recommends 2 x VAR AIC model order
[SSmodel.mosvc,~] = tsdata_to_sssvc(p.Results.X,SSmodel.pf, ... 
    [], p.Results.plotm);
% SS parameters
[SSmodel.A, SSmodel.C, SSmodel.K, ... 
    SSmodel.V] = tsdata_to_ss(X, SSmodel.pf, SSmodel.mosvc);
% SS info: spectrail radius and mii
info = ss_info(SSmodel.A, SSmodel.C, ... 
    SSmodel.K, SSmodel.V, 0);
SSmodel.rhoa = info.rhoA;
SSmodel.rhob = info.rhoB;
SSmodel.mii = info.mii;
end 