function [VARmodel, moest] = VARmodeling(X, varargin)

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
     % VAR model order estimation
    [moest(1),moest(2), moest(3), moest(4)] = ... 
        tsdata_to_varmo(p.Results.X, p.Results.momax,p.Results.moregmode, ...
        [], [], p.Results.plotm);
    % VAR modeling
    [VARmodel.A, VARmodel.V, VARmodel.E] = tsdata_to_var(p.Results.X, ...
        moest(p.Results.mosel),p.Results.moregmode); 
    % Spectral radius
    VARmodel.info = var_info(VARmodel.A,VARmodel.V);
else
     for iepoch = 1:ntrials
        epoch = squeeze(X(:,:,iepoch));
        % VAR model estimation
        [moest(iepoch,1),moest(iepoch,2),moest(iepoch,3),moest(iepoch,4)] = ... 
            tsdata_to_varmo(epoch,p.Results.momax,p.Results.moregmode, ...
        [], [], p.Results.plotm);
        % VAR modeling
        [VARmodel(iepoch).A, VARmodel(iepoch).V, VARmodel(iepoch).E] = ... 
            tsdata_to_var(epoch, ...
                moest(iepoch, p.Results.mosel),p.Results.moregmode);
        VARmodel(iepoch).info = var_info(VARmodel(iepoch).A,VARmodel(iepoch).V);
end

end