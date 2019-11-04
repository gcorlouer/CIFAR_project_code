%Simluate VAR1
nobs=10000;
time=1:1:nobs;
time_series=zeros(1,nobs);
noise= zeros(1,nobs);
for i=1:nobs
    noise(1,i)=normrnd(0,1);
end
phi=0.5;
time_series(1,1)=noise(1,1);
for i=2:nobs
    time_series(1,i)=phi*time_series(1,i-1)+noise(1,i);
end
