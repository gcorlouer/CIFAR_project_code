% Test De chevigne toolbox

%% Import data

subject = 'AnRa';
% 'ppdir','nopreproc'
[X, ts, EEG, filepath,filename,chanstr] = import_ecogdata(subject,'ppdir','nopreproc');
X = EEG.data;

%% Drop bad channels 
drop_chans = [1, 40:51, 59, 60, 61]; % Hyppocampal and unknown regions
EEG =  pop_select(EEG, 'nochannel', drop_chans); % Would be interesting to keep track of ROI
X = EEG.data;

% Data size is time*sample*trials
x = permute(X,[2 1]);

tic 
proportion = 0.50; % half of the time
thresh1 = [];
thresh2 = [];
thresh3 = 5; % Noise amplitude larger than thresh3 median
[iBad,toGood] = nt_find_bad_channels(x,proportion,thresh1,thresh2,thresh3);
toc 

% x(:,iBad) = [];

%% Denoise 

% y=nt_sns(x,nneighbors,skip,w);


%% Detrend 
% Run time 30 sec
order = 10; 
w = []; 
basis= 'sinusoids';  % sinusoid seems to work better
thresh = []; 
niter = []; 
wsize = 10*500;

tic
y = nt_detrend(x,order,w,basis,thresh,niter,wsize);
toc

%% Outliers detection
% Run time 10 mn

tic
w = [];
thresh = 3;
niter = 4;
[w,y_clean] = nt_outliers(y,w,thresh,niter);
toc 
y_clean = permute(y_clean,[2 1]);

noutl = sum(w(:)==0);
%% Trials outlier removal
% Epoch data
y = permute(y,[2 1]);
EEG.data = y;
outEEG=eeg_regepochs(EEG, 'recurrence', 1, 'limits', [0 5]);
y = outEEG.data;
y = permute(y,[2 1 3]);

% trials retrival
tic
criterion = 2; % more than 2 mean deviations
disp_flag = 1;
regress_flag = 0;
[idx,d]=nt_find_outlier_trials(y,criterion,disp_flag,regress_flag);
toc

% Remove bad trials: 

y_clean = y(:,:,idx);
y_clean = permute(y_clean,[2 1 3]);
outEEG.data = y_clean;
pop_eegplot(outEEG);

%% Inpainting 
% Not necessary
% Run time 7 mn can be longer, depend on outlier...
tic
w = [];
[y,yy]=nt_inpaint(y,w);
toc 

%% Visualisation

y = permute(y,[2 1]);
x = permute(x,[2 1]);
EEG.data = y;
EEGx= EEG;
EEGx.data = x;
pop_eegplot(EEG);
pop_eegplot(EEGx);