%% Simulate MVAR model
function [tsdata,ts,var_coef,corr_res] = var_sim(tsdim, morder, specrad, nobs, fs, g, w, ntrials)
%% Argunents
% connect_matrix: matrix of G causal connections
% specrad: spectral radius
% nobs : number of observations
% g = -log(det(R)) where R is the correlation variance exp see corr_rand_exponent
% g is residual multi-information (g = -log|R|): g = 0 yields zero correlation
% w : decay factor of var coefficients
%% 

if nargin < 3,     specrad = 0.98 ;      end
if nargin < 4,     nobs    = 100000;    end
if nargin < 5,     fs      = 500;       end
if nargin < 6,       g     = [];        end 
if nargin < 7,       w     = [];        end
if nargin < 8, ntrials     = 1;         end

ts=1:1/fs:nobs/fs;
connect_matrix=cmatrix(tsdim);
var_coef = var_rand(connect_matrix,morder,specrad,w);
corr_res = corr_rand(tsdim,g); 
tsdata = var_to_tsdata(var_coef,corr_res,nobs,ntrials); 
