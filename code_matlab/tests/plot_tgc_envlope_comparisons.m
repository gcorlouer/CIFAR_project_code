% Data input
tsdim=3;
varmorder = 4;
nobs = 10000;
specrad = 0.98;
connect_matrix=cmatrix(tsdim);
fres=1024;
if ~exist('seed', 'var'), seed  = 0; end % random seed (0 for unseeded)
%if ~exist('plotm','var'), plotm = 0; end % plot mode (figure number offset, or Gnuplot terminal string)
%% Simulate data
[tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
%% Create envelope at multiple frequency bands
fcl_init=80; nbands=4; band_step=10; fs=500; filt_order=128; iir=0;
[multi_envelope,ts_bpass,fcl,fch]=ts2menv(tsdata, fcl_init, nbands, band_step,fs,filt_order,iir);
envelope1=multi_envelope(:,:,1);
envelope2=multi_envelope(:,:,2);
env2compare=cat(1,envelope1,envelope2);
moregmode='LWR'; mosel='LRT'; regmode='LWR'; testats='dual'; alpha=0.05; mhtc='FDR', plotm=1;
[tgc_menv,sigF,sigLR]=ts2tgc_var(env2compare,moregmode,mosel,regmode,testats, alpha, mhtc, plotm)
for i=1:size(envelope1,1)
    for j=1:size(envelope1,1)
    sigF(i,j)=0; 
    sigLR(i,j)=0;
    end 
end
for i=size(envelope2,1):size(env2compare,1)
    for j=size(envelope2,1):size(env2compare,1)
    sigF(i,j)=0;
    sigLR(i,j)=0;
    end 
end

pdata = {tgc_menv;sigF};
title=['PWCGC (estimated) envelope 1=',num2str(fcl(1)),'-',num2str(fcl(2)),'Hz',' envelope2=',num2str(fcl(1)),'-',num2str(fcl(2)),'Hz',' tsdim=', num2str(tsdim)]
ptitle = {title; sprintf('F-test (%s-regression)',testats)};
plot_gc(pdata,ptitle,[],[],plotm);
fname=['gc_compare_envelope_','_envelope2=',num2str(fcl(1)),'-',num2str(fcl(2)),'Hz','_tsdim=', num2str(tsdim)];
fpath=[pwd,'/figures/',fname] ;
saveas(gcf,fpath,'epsc')