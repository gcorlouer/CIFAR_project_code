%Autocorrelation plot tests
%% Data input
tsdim=6;
varmorder = 4;
nobs = 30000;
specrad = 0.98;
connect_matrix=cmatrix(tsdim);
fres=1024;
if ~exist('seed', 'var'), seed  = 0; end % random seed (0 for unseeded)
%if ~exist('plotm','var'), plotm = 0; end % plot mode (figure number offset, or Gnuplot terminal string)
%% Simulate data
[tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
%% Filter data
fpass=1;
fs=500;
ts_highpass = highpass(tsdata,fpass,fs);
%% Autocovariance autocorr
lag= 1000;
autocov = tsdata_to_autocov(ts_highpass,lag);
autocorr = autocov2autocorr(autocov);
%% Plot autocorr
nchans=tsdim
plot_acorr(autocorr,nchans)