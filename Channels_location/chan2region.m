function W=chan2region(X,Y,Z)
%Create a bijection between array of strings 
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
        