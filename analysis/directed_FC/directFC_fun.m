function [DFC_envelope, DFC_ecog, mDFC_envelope, mDFC_ecog, m_sDFC_ecog] = ... 
    directFC_fun(SSmodel_envelope, SSmodel_ecog, connect, CROI, fs, fbin, intBand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute directed functional connectivity on a sliding window according to
% diferent mode of connectivity (inter, intra and pairwise channel)
%%% Input parameters: 
% -SSmodel : State space model on slided time series. SSmodel is a structure
%           with fields : A,V,C,K, model order and spectral radius
% -connect : intra/inter/group
% -CROI : {xchans1-xchans2/x/group
%%% Output 
% - DFC: directed functional connectivity on slided window
% - mDFC: mean directed functional connectivity along sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nwin = size(SSmodel,2);
DFC = zeros(nwin,1);



for w = 1:nwin
    switch connect
        case 'inter'
            DFC_envelope(w) = ss_to_mvgc(SSmodel_envelope(w).A,SSmodel_envelope(w).C,SSmodel_envelope(w).K, ...
            SSmodel_envelope(w).V, CROI{1}, CROI{2});
            sDFC_ecog(w,:) = ss_to_smvgc(SSmodel_ecog(w).A,SSmodel_ecog(w).C,SSmodel_ecog(w).K, ...
            SSmodel_ecog(w).V, CROI{1}, CROI{2}, fbin);
            DFC_ecog(w) = bandlimit(sDFC_ecog(w,:),2,fs,intBand);
        case 'intra'
            DFC_envelpoe(w) = ss_to_cggc(SSmodel_envelope(w).A,SSmodel_envelope(w).C,SSmodel_envelope(w).K, ... 
            SSmodel_envelope(w).V, CROI);
            sDFC_ecog(w) = ss_to_scggc(SSmodel_ecog(w).A,SSmodel_ecog(w).C,SSmodel_ecog(w).K, ...
            SSmodel_ecog(w).V, CROI, fbin);
            DFC_ecog(w) = bandlimit(sDFC_ecog(w,:),2,fs,intBand);
    end
end


mDFC_envelope = mean(DFC_envelope, 1);
mDFC_ecog = mean(DFC_ecog, 1);
m_sDFC_ecog = mean(sDFC_ecog, 1);
end
