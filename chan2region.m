function W=chan2region(X,Y,Z)
%Create a bijection between array of strings with similar strings in different order
%Y might be the electrodes names, Z the electrode location and X chan names
W={};
for i=1:size(X)
    s=X(i);
    if any(strcmp(Y,s))==1; %check s is in Y
        j=find(ismember(Y,s));%look for index of j in Y
        W(i,1)=Z(j,:);
    else
        W(i,1)={'unknown'};
    end
end
end
%To add in the structure array after the transformation has been done do something like:
% for i = 1:nchan, EEG.chanlocs(i).region = chan_region(i); end
        