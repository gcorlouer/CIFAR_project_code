function [SSmodel, moest] = slide_ss(X, ts, fs, wind, tstamp, mosel, momax, moregmode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slide state space modeling on time series
%
%%% Input
% Time series, time window and regression parameters
%%% Output
% State space model inovation form parameters, AIC model order and SVC in 
% each time window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As state space model parameters change size along sliding windows, try to
% Create a structure array instead

if nargin< 6, mosel     = 1;     end % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT

[X, ~, nwin, nwobs, nsobs, ~, ~] = sliding(X, ts, fs, wind, tstamp);

moest = zeros(nwin,1);

% Slide window

for w = 1:nwin
	o = (w-1)*nsobs;      % window offset
	W = X(:, o+1:o+nwobs); % the window\\
	[moest(w,1),moest(w,2),moest(w,3),moest(w,4)] = tsdata_to_varmo(W,momax,moregmode);
    SSmodel(w).pf = 2*moest(w,mosel); %;  % Bauer recommends 2 x VAR AIC model order
    [SSmodel(w).mosvc,~] = tsdata_to_ssmo(W,SSmodel(w).pf);
    [SSmodel(w).A, SSmodel(w).C, SSmodel(w).K, SSmodel(w).V] = tsdata_to_ss(W, SSmodel(w).pf, SSmodel(w).mosvc);
    info = ss_info(SSmodel(w).A, SSmodel(w).C, SSmodel(w).K, SSmodel(w).V, 0);
	SSmodel(w).rhoa = info.rhoA;
	SSmodel(w).rhob = info.rhoB;
	SSmodel(w).mii(w) = info.mii;
end