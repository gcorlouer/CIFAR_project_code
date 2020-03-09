%% Simulate MVAR model
function [tsdata,var_coef,corr_res] = var_sim(connect_matrix, morder, specrad, nobs, g, w, ntrials)
%% Argunents
% connect_matrix: matrix of G causal connections
% specrad: spectral radius
% nobs : number of observations
% g = -log(det(R)) where R is the correlation variance exp see corr_rand_exponent
% g is residual multi-information (g = -log|R|): g = 0 yields zero correlation
% w : decay factor of var coefficients
%% 
if nargin < 5,       g = []; end 
if nargin < 6,       w = []; end
if nargin < 7, ntrials = 1; end
tsdim = size(connect_matrix,1); 
var_coef = var_rand(connect_matrix,morder,specrad,w);
corr_res = corr_rand(tsdim,g); 
tsdata = var_to_tsdata(var_coef,corr_res,nobs,ntrials); 
end