%% Obtain relevant metadat in a table for all subjects accross all tasks. 
%Except for sleep data because it hasn't been configure in a .mat file
%TODO Obtain metadata bout the sleep data
path2subject= [pwd,'/CIFAR_data/iEEG_10/subjects'];
BP = [0 1];
subjects_names=dir(path2subject);
task={'rest_baseline_1','rest_baseline_2','stimuli_1','stimuli_2'};
baseline=[1 2];
%% 
for i=1:(length(subjects_names)-2)
    if i==8 %Subject 'Kial' missing info 
        continue
    end
    for j=1:2
        for k=1:4
            [filepath,filename] = CIFAR_filename(BP(j),subjects_names(i+2).name,task{k});
            [EEG,filepath,filename] = get_EEG_info(BP(j),subjects_names(i+2).name,task{k});
            all_EEG_info(i,j,k)=EEG;
            clear EEG;
        end
    end
end
%% Select dataset
%ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; %preproc directory
for i=1:(length(subjects_names)-2)
    if i==8 %Subject 'Kial' missing info 
        continue
    end
    for j=1:2
        for k=1:length(task)
            all_relevant_EEG_info(i,j,k).subject=i;
            all_relevant_EEG_info(i,j,k).task=task{k};
            all_relevant_EEG_info(i,j,k).bipolar=BP(j);
            all_relevant_EEG_info(i,j,k).nbchan=all_EEG_info(i,j,k).nbchan;
            all_relevant_EEG_info(i,j,k).srate=all_EEG_info(i,j,k).srate;
            all_relevant_EEG_info(i,j,k).pnts=all_EEG_info(i,j,k).pnts;
            all_relevant_EEG_info(i,j,k).nROI=all_EEG_info(i,j,k).SUMA.nROIs;
            all_relevant_EEG_info(i,j,k).seconds=all_relevant_EEG_info(i,j,k).pnts/all_relevant_EEG_info(i,j,k).srate;                
        end
    end
end
%% Save in mat file
save('all_EEG_info.mat','all_EEG_info')
save('all_relevant_EEG_info.mat','all_relevant_EEG_info')
%% Representative metadata description
metadata_rest_raw=all_relevant_EEG_info(:,1,1);
metadata_rest_BP=all_relevant_EEG_info(:,2,1);
metadata_stimuli_raw=all_relevant_EEG_info(:,1,3);
save('metadata_rest_raw.mat','metadata_rest_raw')
save('metadata_rest_BP.mat','metadata_rest_BP')
save('metadata_stimuli_raw.mat','metadata_stimuli_raw')
%% 
T_metadata_rest_raw=struct2table(metadata_rest_raw);
T_metadata_rest_BP=struct2table(metadata_rest_BP);
T_metadata_stimuli_raw=struct2table(metadata_stimuli_raw);
writetable(T_metadata_rest_raw,'metadata_rest_raw.csv');
writetable(T_metadata_rest_BP,'metadata_rest_BP.csv');
writetable(T_metadata_stimuli_raw,'metadata_stimuli_raw.csv');