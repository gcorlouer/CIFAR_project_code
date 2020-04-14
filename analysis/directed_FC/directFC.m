function [DFC, sDFC, mDFC] = directFC(SSmodel, ichan1, ichan2, Band, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Directed functional connectivity on unconditional pairs of channels

%%% Input
%%%%%%%%%
% Required parameters: 
%%%%%%%%%%%%%%%%%%%%%%
% SSmodel: state space model
% ichan1 : channels index in one ROI
% ichan2 : channel index other ROI
% Band : frequency band over which we integrate spectral GC
% Optional parameters :
%%%%%%%%%%%%%%%%%%%%%%%
% Inter: inter regions (2 groups of channels)
% Intra : intra regions (one ROI considered), 
% ichan : channel index of ROI to consider for intra GC
% fbin : frequency bins
% fs : sampling rate
% temporal : temporal or spectral GC
% multitrial: multitrial or epoched data

%%% Output
%%%%%%%%%%
% DFC: directed funcional connectivity (can be a scalar or a matrix)
% mDFC: average DFC over trials
% sDFC : spectral DFC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
defaultInter = true;
defaultMultitrial = true;
defaultTemporal = true;
defaultFbin = 1024;
defaultFs = 500;
defaultIchan = ichan1;

p = inputParser;

addRequired(p,'SSmodel');
addRequired(p,'ichan1');
addRequired(p,'ichan2');
addRequired(p,'Band');
addParameter(p, 'inter', defaultInter, @islogical);
addParameter(p, 'temporal', defaultTemporal, @islogical);
addParameter(p, 'multitrial', defaultMultitrial, @islogical);
addParameter(p, 'fbin', defaultFbin, @isscalar);
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'ichan', defaultIchan);


parse(p, SSmodel, ichan1, ichan2, Band, varargin{:});

if p.Results.multitrial == true 
    if p.Results.inter == true
        if p.Results.temporal == true
            DFC = ss_to_mvgc(p.Results.SSmodel.A, p.Results.SSmodel.C, ...
        p.Results.SSmodel.K, p.Results.SSmodel.V, p.Results.ichan1, p.Results.ichan2);
            mDFC = DFC;
            sDFC = [];
        else
            sDFC = ss_to_smvgc(p.Results.SSmodel.A, p.Results.SSmodel.C, ...
                 p.Results.SSmodel.K,  p.Results.SSmodel.V, ... 
                 p.Results.ichan1, p.Results.ichan2, p.Results.fbin);
            DFC = bandlimit(sDFC, 2, p.Results.fs, p.Results.Band); % check dim
            mDFC = DFC;
        end
    else
        if p.Results.temporal == true
            DFC = ss_to_cggc(p.Results.SSmodel.A, p.Results.SSmodel.C, ...
        p.Results.SSmodel.K, p.Results.SSmodel.V, p.Results.ichan);
            mDFC = DFC;
            sDFC = [];
        else
            sDFC = ss_to_scggc(p.Results.SSmodel.A, p.Results.SSmodel.C, ...
                 p.Results.SSmodel.K,  p.Results.SSmodel.V, p.Results.ichan, p.Results.fbin);
            DFC = bandlimit(sDFC, 1, p.Results.fs, p.Results.Band);
            mDFC = DFC;
        end
    end
else
    nepoch = size(SSmodel, 2);
    if p.Results.inter == true
        if p.Results.temporal == true
            sDFC = [];
            for w = 1:nepoch
                DFC(w) = ss_to_mvgc(p.Results.SSmodel(w).A, p.Results.SSmodel(w).C, ...
            p.Results.SSmodel(w).K, p.Results.SSmodel(w).V, p.Results.ichan1, p.Results.ichan2);
            end
            mDFC = mean(DFC,2);
        else
            for w = 1:nepoch
                sDFC(w,:) = ss_to_smvgc(p.Results.SSmodel(w).A, p.Results.SSmodel(w).C, ...
                     p.Results.SSmodel(w).K,  p.Results.SSmodel(w).V, ... 
                     p.Results.ichan1, p.Results.ichan2, p.Results.fbin);
                DFC(w) = bandlimit(sDFC(w,:), 2, p.Results.fs, p.Results.Band);
            end
            mDFC = mean(DFC,2);
        end
    else
        if p.Results.temporal == true
            sDFC = [];
            for w = 1:nepoch
                DFC(w) = ss_to_cggc(p.Results.SSmodel(w).A, p.Results.SSmodel(w).C, ...
                         p.Results.SSmodel(w).K,  p.Results.SSmodel(w).V, ... 
                         p.Results.ichan);
            end
            mDFC = mean(DFC,2);
        else
            for w = 1:nepoch
                sDFC(w,:) = ss_to_scggc(p.Results.SSmodel(w).A, p.Results.SSmodel(w).C, ...
                         p.Results.SSmodel(w).K,  p.Results.SSmodel(w).V, ...
                         p.Results.ichan, p.Results.fbin);
                DFC(w) = bandlimit(sDFC(w,:), 1, p.Results.fs, p.Results.Band);
            end
            mDFC = mean(DFC,2);
        end
    end
end
end
    



