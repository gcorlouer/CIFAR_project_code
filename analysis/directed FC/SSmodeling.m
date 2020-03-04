function [SSmodel, moest] = SSmodeling(X, ts, varargin)

defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'LWR';

p = inputParser;

addRequired(p,'X');
addRequired(p,'ts');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode, @vector);  

parse(p, X, ts, varargin{:});

[nchan, nobs, ntrials] = size(p.Results.X);

for iepoch = 1:ntrials
    epoch = squeeze(X(:,:,iepoch));
    % VAR model estimation
    [moest(iepoch,1),moest(iepoch,2),moest(iepoch,3),moest(iepoch,4)] = ... 
        tsdata_to_varmo(epoch,p.Results.momax,p.Results.moregmode);
    % SSm svc estimation
    SSmodel(iepoch).pf = 2*moest(iepoch,p.Results.mosel); %;  % Bauer recommends 2 x VAR AIC model order
    [SSmodel(iepoch).mosvc,~] = tsdata_to_ssmo(epoch,SSmodel(iepoch).pf);
    % SS parameters
    [SSmodel(iepoch).A, SSmodel(iepoch).C, SSmodel(iepoch).K, ... 
        SSmodel(iepoch).V] = tsdata_to_ss(epoch, SSmodel(iepoch).pf, SSmodel(iepoch).mosvc);
    % SS info: spectrail radius and mii
    info = ss_info(SSmodel(iepoch).A, SSmodel(iepoch).C, ... 
        SSmodel(iepoch).K, SSmodel(iepoch).V, 0);
	SSmodel(iepoch).rhoa = info.rhoA;
	SSmodel(iepoch).rhob = info.rhoB;
	SSmodel(iepoch).mii(iepoch) = info.mii;
end

% SS stats accross epochs
% meanMoest = mean(moest, 1);
% stdMoest = std(moest, 1);
% SSmodel.meanSvc = SSmodel(:).mosvc
end 