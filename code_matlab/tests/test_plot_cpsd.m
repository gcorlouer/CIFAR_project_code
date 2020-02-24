%% Test saving figure
%% Data input
tsdim=5;
varmorder = 5;
nobs = 30000;
specrad = 0.98;
fres=1024;
if ~exist('seed', 'var'), seed  = 0; end % random seed (0 for unseeded)
%if ~exist('plotm','var'), plotm = 0; end % plot mode (figure number offset, or Gnuplot terminal string)
%% Simulate data
connect_matrix=cmatrix(tsdim) %causal ground truth
iir=1;
[tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
%% Cpsd
fs = 500;
cpsd_name='\cpsd.png';
cpsd_path=[pwd,cpsd_name];
[cpsd_tsdata,f,fres] = tsdata_to_cpsd(tsdata,false,fs,[],[],fres,true,false);
apsd_tsdata_figure_path=[pwd,'\figures\Hilbert_envelope\'];
apsd_tsdata_fname=['varmorder',num2str(varmorder),'_','tsdim', num2str(tsdim),'_','specrad',num2str(specrad),'.png'];
apsd_tsdata_fpath=[apsd_tsdata_figure_path,apsd_tsdata_fname];
figure
plot_autocpsd(cpsd_tsdata,f,fs,tsdim);
saveas(gcf,apsd_tsdata_fpath);