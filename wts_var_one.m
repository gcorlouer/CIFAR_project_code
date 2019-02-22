%Window one time series and model it
n_chan=10;
momax=150;
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
%% Model order estimation
x_slided=squeeze(X_slided(:,:,1));
figure(1); 
ptic('\n*** tsdata_to_varmo... ');
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(x_slided,momax,moregmode);
ptoc;
morder=input('morder=')
%% VAR model
x_slided=squeeze(X_slided(:,:,1));
ptic('\n*** tsdata_to_var... ');
[A,V] = tsdata_to_var(x_slided,morder,regmode);
ptoc;
info = var_info(A,V);
assert(~info.error,'VAR error(s) found - bailing out');
spectral_radius(i,1)=info.rho;