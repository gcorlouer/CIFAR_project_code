%Sliding window time series modeling with vector autoregressive
%Parameters initialisation

momax=25;
moregmode='LWR';
regmode   = 'LWR'; 
T=size(tsdata_pp,2);
L=250; % largeur of sliding window L*downsample/fs sec
num_window=floor(T/L-1);
fpath='/its/home/gc349/CIFAR_guillaume/plots/AnRa/VAR_modeling';%save plots here
for j=1:size(EEG.ROI,1)
    tsdata=X_pp(ROI2num_dic(idx2ROI(j)),:);%select channels
    n_chan=size(x,1);
    %x=x(1:n_chan,:);
%% Define sliding window 
    x_w=zeros(n_chan,L,num_window); 
    for N=1:num_window
        x_w(:,:,N)=x(:,N*L:(N+1)*L-1);
    end 
%% Model order estimation (<mvgc_schema.html#3 |A2|>)
% Calculate and plot VAR model order estimation criteria up to specified maximum model order.
    morders=zeros(num_window,1);
    errlow=zeros(size(morders));
    errhigh=zeros(size(morders));
    for i=1:num_window
        ptic('\n*** tsdata_to_varmo... ');
        [moaic,mobic,mohqc,molrt] = tsdata_to_varmo(squeeze(x_w(:,:,i)),momax,moregmode);
        ptoc;
        morders(i,1)=moselect('HQC','AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
        LRT=moselect('LRT','AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
        BIC=moselect('BIC','AIC',moaic,'BIC',mobic,'HQC',mohqc,'LRT',molrt);
        errlow(i,1)=morders(i,1)-BIC;
        errhigh(i,1)=LRT-morders(i,1);
    end 
%% Barplot model orders with uncertainty bars
    figure;
    sliding_window=1:num_window;
    bar(sliding_window,morders)                
    hold on
    er = errorbar(sliding_window,morders,errlow,errhigh);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    hold off
    title('Model orders along silding window')
    xlabel('Sliding window')
    ylabel('Model order')
    filename=strcat('morder_ROI',num2str(j),'_2sw');
    saveas(gca, fullfile(fpath, filename), 'png');
    close;
%% VAR estimation and spectral radius
    if n_chan==1 
        j=j+1;
    else
        spectral_radius=zeros(num_window,1);
        for i=1:num_window
            ptic('\n*** tsdata_to_var... ');
            [A,V] = tsdata_to_var(squeeze(x_w(:,:,i)),morder,regmode);
            ptoc;
% Check for failed regression
            assert(~isbad(A),'VAR estimation failed - bailing out');
% Report information on the estimated VAR, and check for errors.
% _IMPORTANT:_ We check the VAR model for stability and symmetric
% positive-definite residuals covariance matrix. _THIS CHECK SHOULD ALWAYS BE
% PERFORMED!_ - subsequent routines may fail if there are errors here. If there
% are problems with the data (e.g. non-stationarity, colinearity, etc.) there's
% also a good chance they'll show up at this point - and the diagnostics may
% supply useful information as to what went wrong.
            info = var_info(A,V);
            assert(~info.error,'VAR error(s) found - bailing out');
            spectral_radius(i,1)=info.rho;
        end
        figure;
        bar(sliding_window,spectral_radius);
        title('Spectral radius along silding window')
        xlabel('Sliding window')
        ylabel('Spectral radius')
        ylim([0.8,1])
        filename=strcat('specrad_ROI',num2str(j),'_2sw');
        saveas(gca, fullfile(fpath, filename), 'png');
        close;
    end
end