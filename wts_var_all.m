%Sliding window time series modeling with vector autoregressive
%Parameters initialisation
n_chan=10;
momax=800;
moregmode='LWR';
regmode   = 'LWR';
T=size(X,2);
L=1000; % largeur of sliding window in sec/2
num_window=floor(T/L-1);
X=EEG.data;
X([1,60],:)=[];%get rid of bad channels
X=X(1:n_chan,:);
%% Define sliding window 
X_slided=zeros(n_chan,L,num_window); 
for N=1:num_window
    X_slided(:,:,N)=X(:,N*L:(N+1)*L-1);
end 
%% Model order estimation (<mvgc_schema.html#3 |A2|>)
% Calculate and plot VAR model order estimation criteria up to specified maximum model order.
morders=zeros(num_window,1);
errlow=zeros(size(morders));
errhigh=zeros(size(morders));
for i=1:num_window
    x_slided=squeeze(X_slided(:,:,i));
    figure(1); 
    ptic('\n*** tsdata_to_varmo... ');
    [moaic,mobic,mohqc,molrt] = tsdata_to_varmo(x_slided,momax,moregmode);
    ptoc;
    morders(i,1)=input('morder=')
    errlow(i,1)=input('errlow=')
    errhigh(i,1)=input('errhigh=')
end 
%% Barplot model orders with uncertainty bars
figure(2);
sliding_window=1:num_window;
bar(sliding_window,morders)                
hold on
er = errorbar(sliding_window,morders,errlow,errhigh);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
hold off
title('Model orders along silding window of 20 seconds')
xlabel('Sliding window')
ylabel('Model order')
%% VAR estimation and spectral radius
spectral_radius=zeros(num_window,1);
for i=1:num_window
    x_slided=squeeze(X_slided(:,:,i));
    ptic('\n*** tsdata_to_var... ');
    [A,V] = tsdata_to_var(x_slided,morder,regmode);
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
figure(3);
bar(sliding_window,spectral_radius);
title('Spectral radius along silding window of 20 seconds')
xlabel('Sliding window')
ylabel('Spectral radius')