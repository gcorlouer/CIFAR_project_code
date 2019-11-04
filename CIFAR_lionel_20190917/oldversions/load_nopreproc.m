function [X,FS,filepath,filename] = load_nopreproc(BP,subject,name)

[X,FS,filepath,filename] = load_preproc(BP,subject,name,'nopreproc');
