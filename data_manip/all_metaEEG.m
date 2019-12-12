%% Select subject
BP = [false,true];
path2subject= [pwd,'/CIFAR_data/iEEG_10/subjects'];
subjects_names=dir(path2subject); 
%% Select dataset
%ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; %preproc directory
dataset='freerecall_stimuli_1_preprocessed_BP_montage';
for i=3:length(subjects_names)
    [filepath,filename] = CIFAR_filename(BP(2),subjects_names(i).name,dataset);
    [EEG,filepath,filename] = get_EEG_info(BP(2),subjects_names(i).name,dataset);
    allEEG(i)=EEG;
    allEEG(i).subject=i-2
end
load(strcat(filepath,filesep,filename)); %load metadata containing SUMA mapping
%% Reorganise EEG metadata presentation to keep the relevant info
for i=1:(length(subjects_names)-2)
    all_metadata_EEG_BP(i).subject=allEEG(i+2).subject;
    all_metadata_EEG_BP(i).nbchan=allEEG(i+2).nbchan;
    all_metadata_EEG_BP(i).srate=allEEG(i+2).srate;
    all_metadata_EEG_BP(i).pnts=allEEG(i+2).pnts;
    all_metadata_EEG_BP(i).SUMA=allEEG(i+2).SUMA;
    all_metadata_EEG_BP(i).nROI=allEEG(i+2).SUMA.nROIs
    all_metadata_EEG_BP(i).seconds=all_metadata_EEG_BP(i).pnts/all_metadata_EEG_BP(i).srate
end
%% Get tsdata
bigfile=0;
[X,ts,filepath,filename] = get_EEG_tsdata(BP,subject,dataset,ppdir,bigfile);
%% Select channels
schans=-5; %negative number is ROI, positive is channel
badchans=0;
[chans,chanstr,channames,ogchans] = select_channels(BP,subject,dataset,schans,badchans,[]) %Select unknown chans
%goodchans = get_goodchans(BP,subject,dataset,badchans); 
%% Select dataset
%ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; %preproc directory
dataset='freerecall_stimuli_1_preprocessed';
for i=1:10
    if subjects_names(i+2).name=='KiAl'
        continue
    end
    [filepath,filename] = CIFAR_filename(BP(1),subjects_names(i+2).name,dataset);
    [EEG,filepath,filename] = get_EEG_info(BP(1),subjects_names(i+2).name,dataset);
    allEEG(i)=EEG;
    allEEG(i).subject=i
end
load(strcat(filepath,filesep,filename)); %load metadata containing SUMA mapping
%% Reorganise EEG metadata presentation to keep the relevant info
for i=1:10
    if i==8
        continue
    end
    all_metadata_EEG(i).subject=i;
    all_metadata_EEG(i).nbchan=allEEG(i).nbchan;
    all_metadata_EEG(i).srate=allEEG(i).srate;
    all_metadata_EEG(i).pnts=allEEG(i).pnts;
    all_metadata_EEG(i).SUMA=allEEG(i).SUMA;
    all_metadata_EEG(i).nROI=allEEG(i).SUMA.nROIs
    all_metadata_EEG(i).seconds=all_metadata_EEG(i).pnts/all_metadata_EEG(i).srate
end
save('all_metadata_EEG.mat','all_metadata_EEG')