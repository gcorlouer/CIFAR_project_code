%initialize parameters 
%x,n_i,n_f,wlag,Nobs,nchan,chan_i,chan_f
x=EEG.data;
nchan=10;
t=EEG.times;
chan_i=3;
chan_f=13;
n_i=1;
n_f=10000;
Nobs=EEG.pnts;
wlag=5000;
fs=EEG.srate;
fres=2^11;
X=x(chan_i:chan_f,n_i:n_f);

