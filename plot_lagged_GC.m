%Plot output of windowed mvgc
n_lags=floor((Nobs-n_f)/wlag);
max_F_time=zeros(1,n_lags)%Take maximum of time domain Granger causality
for j=1:n_lags
    max_F_time(j)=max(F_time(:,:,j),[],[1 2]);
end
figure('Name','Time domain GC','NumberTitle','off');clf;%Plot grids of GC betweenn different channels (note that if two many channels
%then there is a risk that figure will not hold all subplots
for j=1:n_lags
    maxF = 1.1*nanmax(F_time(:,j));
    subplot(floor(sqrt(n_lags))+1,floor(sqrt(n_lags))+1,j)
    plot_pw(F_time(:,:,j),'PWCGC (estimated)',[],maxF);
    title(strcat('lag',num2str(j)))
end
figure('Name','Model orders per shift','NumberTitle','off');clf;%Plot model order at each shift
plot(morders,'rx')
figure('Name','Spectral radius per shift','NumberTitle','off');clf;%Plot Spectral Radius at each shift
plot(WAR_spectral_radius,'rx')
figure('Name','F_max per shift','NumberTitle','off');clf;%Plot max of temporal GC per chisft
plot(max_F_time,'rx')
figure('Name','Spectral domain GC chan 3 and 4','NumberTitle','off');clf;%PLot spectral GC between two channels
for j=1:n_lags
    subplot(floor(sqrt(n_lags))+1,floor(sqrt(n_lags))+1,j)
    plot(squeeze(freqs(:,1)),squeeze(F_spec(3,4,:,j)));
    title(strcat('lag',num2str(j)))
end
% figure('Name','Significance F-test Time domain GC','NumberTitle','off')
% sigF  = significance(stats.(tstats).F.pval, alpha,mhtc);
% sigLR = significance(stats.(tstats).LR.pval,alpha,mhtc);
% for j=1:n_lags
%     subplot(floor(sqrt(n_lags))+1,floor(sqrt(n_lags))+1,j)
%     plot_pw(sigF,sprintf('F-test (%s-regression)\nSignificant at p = %g',tstats));
%     title(strcat('lag',num2str(j)))
% end
% figure('Name','Significance LR test Time domain GC','NumberTitle','off')
% for j=1:n_lags
%     subplot(floor(sqrt(n_lags))+1,floor(sqrt(n_lags))+1,j)
%     plot_pw(sigLR,sprintf('LR test (%s-regression)\nSignificant at p = %g',tstats));
%     title(strcat('lag',num2str(j)))
% end
% figure('Name','Spectral domain GC','NumberTitle','off')
% for j=1:n_lags
%     subplot(floor(sqrt(n_lags))+1,floor(sqrt(n_lags))+1,j)
%     plot_spw(F_spec(:,:,:,j),freqs,'Spectral Granger causalities ');;
%     title(strcat('lag',num2str(j)))
% end