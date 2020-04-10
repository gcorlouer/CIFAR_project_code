function [sDFC, DFC, mDFC] = sinterDFC(SSmodel, ichan1, ... 
    ichan2, multitrial, fs, fbin, Band)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute directed functional connectivity on a sliding window according to
% diferent mode of connectivity (inter, intra and pairwise channel)
%%% Input parameters: 
% - SSmodel : State space model  (envelope or ECoG) on slided time series.
%             SSmodel is a structure
%             with fields : A,V,C,K, model order and spectral radius
% - ichan     : selected paired channel for DFC
% 
%%% Output 
%
% - DFC: directed functional connectivity on slided window
% - mDFC: mean directed functional connectivity along sliding window
%
% TODO
% Condition on other channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if multitrial == true
    % Spectral GC
    sDFC = ss_to_smvgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V, ... 
        ichan1, ichan2, fbin);
    % Integration of spectral GC on specific frequency band
    DFC = bandlimit(sDFC, 2, fs, Band);
    mDFC = DFC;
else
    nepoch = size(SSmodel, 2);
    for w = 1:nepoch
        % Spectral GC on epoch
        sDFC(w,:) = ss_to_smvgc(SSmodel(w).A, SSmodel(w).C, ...
            SSmodel(w).K, SSmodel(w).V, ichan1, ichan2, fbin);
        % Integration of spectral GC on specific frequency band
        DFC(w) = bandlimit(sDFC(w,:), 2, fs, Band);
    end
    % Average over epochs
    mDFC = mean(DFC(w),2);
end

end