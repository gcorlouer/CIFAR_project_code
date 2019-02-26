#Transform mni coordinate to correspinding region in the brain and output a csv file 
fpath='/its/home/gc349/CIFAR_data/CIFAR/iEEG_10/subjects/AnRa/EEGLAB_datasets/bipolar_montage'
fname='/MNI_AnRa.csv'
m<-read.csv(paste0(fpath,fname))
rows=nrow(m)
Result <- t(mapply(FUN = mni_to_region_name, x = m$mni_x, y = m$mni_y, z = m$mni_z))#transform mni coordinates to regions 
write.csv(Result, file='AnRa_labeled_region.csv')#write a csv file
