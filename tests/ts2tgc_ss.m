%% Compute temporal Granger causality from time series via state space model
function [tgc,A,C,Kalman_gain,variance, ssmomax]=ts2tgc_ss(tsdata, alpha, moregmode, momax)
%% TODO
%% Parameters
% A,C,K,V are innovation form state space model parameters
% ssmo: state space model order
% Usually 
% moregmode = 'LWR';   % VAR model estimation regression mode ('OLS' or 'LWR')
% mosel     = 'LRT';   % model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)

%% Input param 

if nargin < 4 momax     = 20 ;    end
if nargin < 3 moregmode = 'LWR' ; end
if nargin < 2 alpha     = [];     end

%% VAR modeling of tsdata

[moaic,~,~,~] = tsdata_to_varmo(tsdata,momax,moregmode,alpha);

morder = moaic;

%% SS model order estimation of tsdata

pf = 2*morder;  % Bauer recommends 2 x VAR AIC model order

[mosvc,ssmomax] = tsdata_to_ssmo(tsdata,pf);

%% SS model estimation of tsdata

% Estimate SS model order and model paramaters

[A,C,Kalman_gain,variance] = tsdata_to_ss(tsdata,pf,mosvc);

%% Granger causality calculation: time domain

% Estimated time-domain pairwise-conditional Granger causalities

tgc = ss_to_pwcgc(A,C,Kalman_gain,variance);
