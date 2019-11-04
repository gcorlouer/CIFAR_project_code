function isAny=multiStrFind(cellToSearchIn,stringsToMatch)
    if ~iscell(stringsToMatch)
        stringsToMatch={stringsToMatch};
    end    
    cellToSearchIn(cellfun(@(x) isequal(x,nan),cellToSearchIn))=repmat({''},sum(cellfun(@(x) isequal(x,nan),cellToSearchIn)),1);
    cellToSearchIn(cellfun(@isempty,cellToSearchIn))=repmat({''},sum(cellfun(@isempty,cellToSearchIn)),1);
    isAny=false(size(cellToSearchIn));
    for i=1:numel(stringsToMatch)
        isAny(cellfun(@(c) ~isempty(c),strfind(cellToSearchIn,stringsToMatch{i})))=true;
    end
end