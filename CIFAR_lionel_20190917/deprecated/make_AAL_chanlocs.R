# In R
#
# eegfile<-c("/home/cogs/csai/lionelb/data/CIFAR/iEEG_10/subjects/AnRa/EEGLAB_datasets/raw_signal/AnRa_freerecall_rest_baseline_1_preprocessed")
# source("~/localrepo/matlab/ncomp/CIFAR/preproc/save_AAL_labels.R")
#
# From command line
#
# Rscript ~/localrepo/matlab/ncomp/CIFAR/preproc/save_AAL_labels.R /home/cogs/csai/lionelb/data/CIFAR/iEEG_10/subjects/DiAs/EEGLAB_datasets/raw_signal/DiAs_freerecall_rest_baseline_1_preprocessed

library(R.matlab)
library(label4MRI)

data<-readMat("/tmp/coords.mat")

chanlocs<-as.data.frame(data$coords)

colnames(chanlocs)<-c("x","y","z")

res<-t(mapply(FUN=mni_to_region_name, x=chanlocs$x, y=chanlocs$y, z=chanlocs$z, template=c("aal")))

write.csv(res,"/tmp/labels.csv")
