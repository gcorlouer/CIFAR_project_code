%% Enveloppe exctraction tests
%% TODO:    
%Compare GC envelope with GC envelope of different frequencies band
%Compare GC phase  
%Temporal and spectral   
%GC between phase and amplitude  
%% Data input
tsdim=3;
varmorder = 4;
nobs = 20000;
specrad = 0.98;
connect_matrix=cmatrix(tsdim);
fres=1024;
if ~exist('seed', 'var'), seed  = 0; end % random seed (0 for unseeded)
%if ~exist('plotm','var'), plotm = 0; end % plot mode (figure number offset, or Gnuplot terminal string)
%% Simulate data
[tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
%% Filter data 
iir=1;
[fs,fcut_low_1,fcut_high_1,filt_order, fir]=deal(500,80,100,128,0);
tsdata_bp_1=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, iir);

iir=1;
[fs,fcut_low_2,fcut_high_2,filt_order, fir]=deal(500,100,120,128,0);
tsdata_bp_2=tsdata2ts_filtered(tsdata,fs,fcut_low_2,fcut_high_2,filt_order, iir);
%% Envelope extraction
envelope_1 = tsdata2envelope(tsdata_bp_1);
envelope_2 = tsdata2envelope(tsdata_bp_2);
%% Compute temporal gc with state space
moregmode = 'LWR';   % VAR model estimation regression mode ('OLS' or 'LWR')
mosel     = 'LRT';   % model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
momax=50;
plotm=1;
[tgc_ss_1,A_1,C_1,Kalman_gain_1,variance_1, ssmo_1]=ts2sgc_ss(envelope_1, moregmode, mosel, momax, plotm);
plotm=plotm+1;
[tgc_ss_2,A_2,C_2,Kalman_gain_2,variance_2, ssmo_2]=ts2sgc_ss(envelope_2, moregmode, mosel, momax, plotm);
%%  Plot GC

