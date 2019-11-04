% For any ROI output all channels indices in this ROI
function dict=region2chan(Lr,ROI)
keySet=ROI;%Cell of regions of interests
valueSet=cell(size(ROI));
for i=1:size(ROI)
    S=ROI(i);
    idx= strfind(Lr,S);%find index of a certain region in chan number list
    chans=[];
    chans = find(not(cellfun('isempty', idx)));%Create list of chans in region S
    valueSet{i}=chans;
end
dict=containers.Map(keySet, valueSet, 'UniformValues',false);
end