%Window one time series and model it 
momax=25;
moregmode='LWR';
regmode   = 'LWR';
L=50000; % largeur of sliding window 
X=X_pp;
X([12:127],:)=[];%get rid of some channels
n_chan=size(X,1)
T=size(X,2);
num_window=floor(T/L-1);
%% Define sliding window 
X_slided=zeros(n_chan,L,num_window); 
for N=1:num_window
    X_slided(:,:,N)=X(:,N*L:(N+1)*L-1);
end %Maybe better to create a function that does it as this is something we well use recurrently
%% Model order estimation
x_slided=squeeze(X_slided(:,:,1)); %Create If then condition for rolling  just over one ?
figure(1); 
ptic('\n*** tsdata_to_varmo... ');
[moaic,mobic,mohqc,molrt] = tsdata_to_varmo(x_slided,momax,moregmode);
ptoc;
morder=input('morder=')
%% VAR model
ptic('\n*** tsdata_to_var... ');
[A,V] = tsdata_to_var(x_slided,morder,regmode);
ptoc;
info = var_info(A,V);
assert(~info.error,'VAR error(s) found - bailing out');