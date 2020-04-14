function [SSmodel, moest] = SSmodeling(X, varargin)

defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'LWR';
defaultPlotm = 1;
defaultMultitrial = true;

p = inputParser;

addRequired(p,'X');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode, @vector);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);  
addParameter(p, 'multitrial', defaultMultitrial, @islogical);  

parse(p, X, varargin{:});

[nchan, nobs, ntrials] = size(p.Results.X);

if p.Results.multitrial == true
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
else
    for iepoch = 1:ntrials
        epoch = squeeze(X(:,:,iepoch));
        % VAR model estimation
        [moest(iepoch,1),moest(iepoch,2),moest(iepoch,3),moest(iepoch,4)] = ... 
            tsdata_to_varmo(epoch,p.Results.momax,p.Results.moregmode);
        % SSm svc estimation
        SSmodel(iepoch).pf = 2*moest(iepoch,p.Results.mosel); %;  % Bauer recommends 2 x VAR AIC model order
        [SSmodel(iepoch).mosvc,~] = tsdata_to_sssvc(epoch,SSmodel(iepoch).pf, ... 
            [], p.Results.plotm);
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
end

% SS stats accross epochs
% meanMoest = mean(moest, 1);
% stdMoest = std(moest, 1);
% SSmodel.meanSvc = SSmodel(:).mosvc
end 