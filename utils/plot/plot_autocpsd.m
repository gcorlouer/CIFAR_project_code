%% Plot autospec
%Plot autospectral density
function plot_autocpsd(cpsd,f,fs,nchans)
log_cpsd=20*log10(cpsd);
plot(f,log_cpsd);
xlabel('frequency (Hz)');
ylabel('power (dB)');
xlim([0 fs/2]);
grid on
chan_names=cell(nchans,1);
for i=1:nchans
    chan_names(i)={['chan',num2str(i)]};
end
if nchans <= 40
    legend(chan_names);
end