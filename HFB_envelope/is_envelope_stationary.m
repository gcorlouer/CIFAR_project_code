%% Test if envelope is stationary and stability of VAR modeling
nband=5;
band=zeros(nband,1);
band_step=20;
band(1)=60;
for iband=1:nband-1
band(iband+1)=band(iband)+band_step;
end
for k=1:nband-1
    tsdim=6;
    varmorder = 4;
    nobs = 25000;
    specrad = 0.98;
    fs=500;
    fig_filepath= [pwd, '/figures/envelope_stationarity_sim/']
    connect_matrix=cmatrix(tsdim);
    %% Simulate data
    [tsdata,var_coef_ts,corr_res_ts]=var_sim(connect_matrix, varmorder, specrad, nobs);
    %% Filter data 
    iir=0;

    [fs,fcut_low,fcut_high,filt_order, fir]=deal(500,band(k),band(k+1),138,0);
    tsdata_filtered=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, iir);

    %% Envelope extraction
    envelope = tsdata2envelope(tsdata_filtered);
    %% Windows slicing
    wind      = [5 0.1];  % window width and slide time (secs)
    tstamp    = 'mid';   % window time stamp: 'start', 'mid', or 'end'
    verb      = 2;    %verbosity
    fignum    = 1;  % figure number
    ts=1:1/500:nobs/500;
    [envelope,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(envelope,ts,fs,wind,tstamp,verb);
    [nchans,nobs] = size(envelope);
    %% Mean standard deviation estimation over sliding window
    m = zeros(nwin,nchans); mmean = zeros(nwin,1);
    s = zeros(nwin,nchans); smean = zeros(nwin,1);
    for w = 1:nwin
        fprintf('window %4d of %d : ',w,nwin);
        o = (w-1)*nsobs;      % window offset
        W = envelope(:,o+1:o+nwobs); % the window
        m(w,:) = mean(W'); mmean(w) = mean(m(w,:));
        s(w,:) = std(W');  smean(w) = mean(s(w,:));
        fprintf('mean = % 8.4f, sdev = %7.4f\n',mmean(w),smean(w));
    end
    if ~isempty(fignum)

        %center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

        yyaxis left
        plot(tsw,mmean);
        ylabel('mean mean');
        yyaxis right
        plot(tsw,smean);
        xlim([ts(1) ts(end)]);
        ylabel('mean std. dev.');
        xlabel('time (secs)');

        fig_filepath= [pwd, '/figures/envelope_stationarity_sim/']
        fig_filename_mean_std=['mean_std_tsdim_',num2str(tsdim),'_varmorder_',num2str(varmorder),'_',num2str(fcut_low),'_',num2str(fcut_high) ,'Hz_','_wind_',num2str(wind(1)),'s.fig']
        fig_title_mean_std=['Mean standard deviation of a ',num2str(fcut_low),'-',num2str(fcut_high) ,' Hz envelope of a ',num2str(tsdim), ' dim VAR(',num2str(varmorder) ,') model along ',num2str(wind(1)),'s',' sliding window']
        title(fig_title_mean_std)
        saveas(gcf,[fig_filepath,fig_filename_mean_std]);
    end
    close all
    %% VAR model order estimate
    maxmo     = 15;      % maximum AR model order
    moregmode = 'LWR';   % AR model order regression mode
    ylims     = [1 9];   % y-axis limits

    moest = zeros(nwin,4);
    for w = 1:nwin
        fprintf('window %4d of %d : ',w,nwin);
        o = (w-1)*nsobs; % window offset
        W = envelope(:,o+1:o+nwobs);  % the window
        [moest(w,1),moest(w,2),moest(w,3),moest(w,4)] = tsdata_to_varmo(W,maxmo,moregmode);
        fprintf('AIC = %2d, BIC = %2d, HQC = %2d, LRT = %2d\n',moest(w,1),moest(w,2),moest(w,3),moest(w,4));
    end

    if ~isempty(fignum)

        %center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

        plot(tsw,moest(:,2:3));
        xlim([ts(1) ts(end)]);
        xlabel('time (secs)');
        ylabel('VAR model order');
        %legend({'AIC','BIC','HQC','LRT'});
        legend({'BIC','HQC'});
        fig_filename_varmorder=['varegmorder_','varsim_',num2str(tsdim),'_varmorder_',num2str(varmorder),'_',num2str(fcut_low),'_',num2str(fcut_high) ,'Hz_','_wind_',num2str(wind(1)),'s.fig']
        fig_title_varmorder=['VAR model order estimation of a ',num2str(fcut_low),'-',num2str(fcut_high) ,' Hz envelope of a ',num2str(tsdim), ' dim VAR(',num2str(varmorder) ,') model along ',num2str(wind(1)),'s',' sliding window']
        title(fig_title_varmorder)
        saveas(gcf,[fig_filepath,fig_filename_varmorder]);
    end
    close all
    %% VAR model estimate    
    regmode   = 'OLS';   % AR model estimation regression mode
    mosel     = 2;       % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT

    rho = zeros(nwin,1);
    mii = zeros(nwin,1);
    for w = 1:nwin
        fprintf('window %4d of %d : ',w,nwin);
        o = (w-1)*nsobs;      % window offset
        W = envelope(:,o+1:o+nwobs); % the window
        [A,V] = tsdata_to_var(W,moest(w,mosel),regmode);
        info = var_info(A,V,0);
        rho(w) = info.rho;
        mii(w) = info.mii;
        fprintf('rho = %6.4f, mii = %6.4f\n',rho(w),mii(w));
    end

    if ~isempty(fignum)

        %center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

        yyaxis left
        plot(tsw,rho);
        ylabel('spectral radius');
        yyaxis right
        plot(tsw,mii);
        xlim([ts(1) ts(end)]);
        ylabel('residuals multi-information');
        xlabel('time (secs)');
        fig_filename_varmo=['specrad_','mosel',num2str(mosel),'_varsim_',num2str(tsdim),'_varmorder_',num2str(varmorder),'_',num2str(fcut_low),'_',num2str(fcut_high) ,'Hz_','_wind_',num2str(wind(1)),'s.fig']
        fig_title_varmo=['Spectral radius estimation of a ',num2str(fcut_low),'-',num2str(fcut_high) ,' Hz envelope of a ',num2str(tsdim), ' dim VAR(',num2str(varmorder) ,') model along ',num2str(wind(1)),'s',' sliding window']
        title(fig_title_varmo)
        saveas(gcf,[fig_filepath,fig_filename_varmo]);
    end
    close all
end
