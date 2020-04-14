function [DFC_envelope, DFC_ecog, mDFC_envelope, mDFC_ecog, m_sDFC_ecog] = ... 
    directFC_test(SSmodel_envelope, SSmodel_ecog, ichan1 , ichan2, fs, fbin, Band)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute directed functional connectivity on a sliding window according to
% diferent mode of connectivity (inter, intra and pairwise channel)
%%% Input parameters: 
% - SSmodel : State space model  (envelope or ECoG) on slided time series.
%             SSmodel is a structure
%             with fields : A,V,C,K, model order and spectral radius
% - ROI     : selected ROI for analysis
% 
%%% Output 
%
% - DFC: directed functional connectivity on slided window
% - mDFC: mean directed functional connectivity along sliding window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nepoch = size(SSmodel_envelope,2);

for w = 1:nepoch
    % GC of the envelope between 2 ROIs 
    DFC_envelope(w) = ss_to_mvgc(SSmodel_envelope(w).A, SSmodel_envelope(w).C, ...
        SSmodel_envelope(w).K, SSmodel_envelope(w).V, ichan1, ichan2);
    % Spectral GC betweenn ROI
    sDFC_ecog(w,:) = ss_to_smvgc(SSmodel_ecog(w).A,SSmodel_ecog(w).C, ... 
        SSmodel_ecog(w).K, SSmodel_ecog(w).V, ichan1, ichan2, fbin);
    % Integration of spectral GC on specific frequency band
    DFC_ecog(w) = bandlimit(sDFC_ecog(w,:), 2, fs, Band);
end

mDFC_envelope = mean(DFC_envelope, 2);
mDFC_ecog = mean(DFC_ecog, 2);
m_sDFC_ecog = mean(sDFC_ecog, 1);

end