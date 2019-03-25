%Window one time series and model it 
momax=25;
moregmode='LWR';
regmode   = 'LWR';
L=5000; % largeur of sliding window 
x=X_pp;
x=x(ROI2num_dic(idx2ROI(8)),:);%select some channels
n_chan=size(x,1);
T=size(x,2);
num_window=floor(T/L-1);
%% Define sliding window 
x_slided=zeros(n_chan,L,num_window); 
for N=1:num_window
    x_slided(:,:,N)=x(:,N*L:(N+1)*L-1);
end %Maybe better to create a function that does it as this is something we well use recurrently
%% Model order estimation
x_slided=squeeze(x_slided(:,:,1)); %Create If then condition for rolling  just over one ?
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