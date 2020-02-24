function awcpsd2saclogram(awcpsd,twindow,freq)

if size(twindow,2)>size(twindow,1)
    window_size=size(twindow,2);
else
    window_size=size(twindow,1);
end
if size(freq,2)>size(freq,1)
    nfreq=size(freq,2);
else
    nfreq=size(freq,1);
end
mean_awcpsd=zeros(nfreq,window_size);

mean_awcpsd(:,:) = mean(awcpsd,1);
log_awcpsd = 20*log10(mean_awcpsd);

pcolor(twindow,freq,log_awcpsd)
shading flat
set(gca,'YScale','log')
xlabel('Time (Samples)')
ylabel('Normalized Frequency (cycles/sample)')
title('Scalogram')
colorbar