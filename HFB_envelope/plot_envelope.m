%% Plot envelope and signl
function plot_envelope(tsdata,envelope,trange, chanum, fs)
%TODO possible extension: multiple channels, sampling rate, chanum must
%appears on title
%% Arguments
% tsdata: input time series 
% envelope: envelope of time series
% trange: range of observations
% chanum : channel number to plot
%%
dt=1/fs; 
plot_param = {'Color', [0.6 0.1 0.2],'Linewidth',2}; 
plot(trange,tsdata(chanum,trange))
hold on
plot(trange, envelope(chanum,trange),plot_param{:})
hold off
xt = get(gca, 'XTick');                                 
set(gca, 'XTick', xt, 'XTickLabel', xt/fs)  
xlabel('Time (sec)')
ylabel('Potential (mV)')
legend('Signal','Envelope')