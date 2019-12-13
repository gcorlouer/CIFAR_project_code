%% Testing wavelets
%To do: choose reasonable freq interval
%the code is shit
%% Data input
tsdim=5;
varmorder = 4;
nobs = 30000;
specrad = 0.98;
connect_matrix=cmatrix(tsdim);
fres=1024;
if ~exist('seed',   'var'), seed     = 0;    end % random seed (0 for unseeded)
if ~exist('svconly','var'), svconly  = true; end % only compute SVC for SS model order selection (faster)
if ~exist('plotm',  'var'), plotm    = 0;    end % plot mode (figure number offset, or Gnuplot terminal string)
%% Simulate data
[tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
%% Estimate wcpsd
fs=500;
pad0=1;
freq=1:0.1:fs/2;
omega0=6;
nchans=size(tsdata,1);
nobs=size(tsdata,2);
ntrial=1;
wind=5000:7000;
ts_wind=zeros(tsdim,length(wind),ntrial);
ts_wind(:,:,1)=tsdata(:,wind);
[S, COH, iCOH] = xwt_cmorl_nv(ts_wind,fs,freq,pad0,omega0);
chan=1;
time_sel=10;
for i=1:tsdim
    cpsd(i,:)=S(i,i,:,time_sel);
end
plot_autocpsd(cpsd,freq,fs,nchans)