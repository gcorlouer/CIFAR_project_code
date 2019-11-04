#MNI_conversion
#This script upload an MNI matlab matrix and it gives you precise MNI info.

# https://github.com/yunshiuan/label4MRI

#Install required packages (if you don't have them)
install.packages("here")
install.packages("R.matlab")


#Libraries
library(R.matlab)
library(label4MRI)
library(here)

#Paths
here("Desktop", "MNI", "chanlocs.mat")

#Import
data<-readMat(here("Desktop", "MNI", "chanlocs.mat"))

#Extract chanlocs
chanlocs<-data$chanlocs

#Convert to dataframe
chanlocs<-as.data.frame(chanlocs)

#Rename col names
colnames(chanlocs) <- c("x","y","z")

#Run the code
res<-t(mapply(FUN = mni_to_region_name, x = chanlocs$x, y = chanlocs$y, z = chanlocs$z, template = c("aal")))

#Save as CSV
write.csv(res,"/tmp/chanloc_labels.csv")
