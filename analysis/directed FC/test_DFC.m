% Test DFC

sDFC = ss_to_scggc(SSmodel.A, SSmodel.C, ...
                 SSmodel.K,  SSmodel.V, ichan2, fbin);
DFC = bandlimit(sDFC, 1, fs, Band);

sDFC = ss_to_smvgc(SSmodel.A, SSmodel.C, ...
                 SSmodel.K, SSmodel.V, ... 
                 ichan1, ichan2, fbin);
DFC = bandlimit(sDFC, 2, fs, Band); % check dim