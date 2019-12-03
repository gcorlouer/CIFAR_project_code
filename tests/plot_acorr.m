function plot_acorr(autocorr,nchans)
lag=size(autocorr,3);
lags=1:lag;
acorr=zeros(nchans,lag);
for i=1:nchans
    acorr(i,:)=autocorr(i,i,:);
end
plot(lags,acorr)
xlabel('lags');
ylabel('autocorr');
grid on
chan_names=cell(nchans,1);
for i=1:nchans
    chan_names(i)={['chan',num2str(i)]};
end
if nchans <= 40
    legend(chan_names);
end
