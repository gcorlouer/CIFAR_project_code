function corr_ts=tsdata2corr(tsdata)
%Take time series data and plot correlation between channels
SIG=cov(tsdata');%data must be along rows and channels colunmn
corr_ts=cov2corr(SIG);
%Visualise correlation as heatmap
imagesc(corr_ts);
colorbar
colormap('hot');
