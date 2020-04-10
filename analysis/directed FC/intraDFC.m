function [DFC, mDFC] = intraDFC(SSmodel_envelope, ichan, multitrial)

if multitrial == true
    DFC = ss_to_cggc(SSmodel_envelope.A,SSmodel_envelope.C,SSmodel_envelope(w).K, ... 
        SSmodel_envelope.V, ichan);
    mDFC = DFC;
else 
    nepoch = size(SSmodel, 2);
    for w = 1:nepoch
        DFC(w) = ss_to_cggc(SSmodel_envelope(w).A,SSmodel_envelope(w).C,SSmodel_envelope(w).K, ... 
        SSmodel_envelope(w).V, ichan);
    end
    mDFC =  mean(DFC(w),2);
end
end
