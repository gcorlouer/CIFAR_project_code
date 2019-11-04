%Configure data for all subjects, all montages, except sleep data. 
path2subjects=cfsubdir;
subjects_names=dir(path2subjects); 
for i=3:size(subjects_names);
    subject=subjects_names(i).name;
    BP=0;
    configure_data;
    BP=1;
    configure_data;
end

