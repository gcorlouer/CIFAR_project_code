%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Descriptive statistics script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
BP = 0; subject = 'AnRa'; task = 'rest_baseline_1'; ppdir='preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';
figsave=false;
bigfile=false;
fres=1024;
fhi=250;
fig_filepath= [pwd, '/figures/stationarity/']
%% Pick up data and channels
% Analyse mean and std in all ROI

cd '~/CIFAR_guillaume' %CIFAR directory
cd 'CIFAR_data/iEEG_10/subjects' %Subject dir
BP = 1; subject = 'AnRa'; task = 'rest_baseline_1';
figsave=false;
tseg      = [1 30];     % start/end times (empty for entire time series)
ds        = 1;      % downsample factor

if BP==0
    ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';
    schans    = -6;      % selected channels (empty for all good, negative for ROI number)
    badchans  = 0;       % bad channels (empty for none)
    [EEG,filepath,filename] = get_EEG_info(BP,subject,task);
    [chans,chanstr] = select_channels(BP,subject,task,schans,badchans,1);
    [X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,1);

else
    ppdir='preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';
    numchan=10 %Pick numchan random channels
    nobs=25000;
    [EEG,filepath,filename] = get_EEG_info(BP,subject,task);
    chans=randi([1 EEG.nbchan],[numchan 1]);
    chanstr = sprintf('channels%s',sprintf(' %d',chans));
    [X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,1);
end
cd ..; cd ..; cd .. ;
%% Check cpsd
%So far 2 channels seems spurious looking at cpsd, since we randomly pick
%them, it is worth checking if they are ok

[S,f,fres] = tsdata_to_cpsd(X,false,fs,[],[],fres,true,false); % auto-spectra
S = 20*log10(S); % measure power as log-mean across channels (dB)


%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

plot(f,S);

xlabel('frequency (Hz)');
ylabel('power (dB)');
xlim([0 fhi]);
grid on
%% Slice ts

wind      = [5 0.1]; 
[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);
[nchans,nobs] = size(X);
%% VAR model order

moest=sliding_varmorder(X,ts,nwin,nsobs,nwobs,tsw);

fig_filename=['varmorder_',filename,'_wind_',num2str(wind(1)),'s.fig'];
title_head=strsplit(filename,'_'); 
title_head=strjoin(title_head)
fig_title=[title_head,', VAR model order estimation along ',num2str(wind(1)),'s',' sliding window ',chanstr,];
title(fig_title)
saveas(gcf,[fig_filepath,fig_filename]);
%% State space model order
mosel     = 1;  % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
pf = 2*moest(:,mosel); % (Bauer: 2*aic for mosel == 1)

mosvc = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[mosvc(w),ssmomax] = tsdata_to_ssmo(W,pf(w));
	fprintf('mosvc = %d\n',mosvc(w));
end

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	figure(fignum); clf;
	plot(tsw,mosvc);
	ylabel('SS model order');
	xlim([ts(1) ts(end)]);
	xlabel('time (secs)');
end
%% SS model statistics
rhoa = zeros(nwin,1);
rhob = zeros(nwin,1);
mii  = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[A,C,K,V] = tsdata_to_ss(W,pf(w),mosvc(w));
	info = ss_info(A,C,K,V,0);
	rhoa(w) = info.rhoA;
	rhob(w) = info.rhoB;
	mii(w)  = info.mii;
	fprintf('AR rho = %6.4f, MA rho = %6.4f, mii = %6.4f\n',rhoa(w),rhob(w),mii(w));
end

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	figure(fignum); clf;
	yyaxis left
	plot(tsw,-log(1-[rhoa rhob]));
	ylabel('-log(1-specrad)');
	yyaxis right
	plot(tsw,mii);
	xlim([ts(1) ts(end)]);
	ylabel('residuals multi-information');
	xlabel('time (secs)');
	legend({'AR','MA','MII'});

	[filepath,filename] = CIFAR_filename(BP,subject,task);
    if BP==0
        chanstr=sprintf('channels%s',sprintf(' %d',chans));
    end
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end

% for i=1:nROIs
%     schans=-i;
%     if schans==-18 %No channel in ROI 18 ! 
%         continue
%     end
%     run sliding_meanstd.m;
%     figname=strcat('sliding_meanstd_',filename,'_raw_signal','.fig');
%     newfigname=strcat('sliding_meanstd_',filename,'_raw_signal','_ROI_',num2str(-schans),'.fig');
%     movefile(figname,newfigname)
%     movefile(newfigname,'/its/home/gc349/CIFAR_guillaume/figures/AnRa/stationarity');
% end
