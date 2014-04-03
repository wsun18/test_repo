function ind = findindex4stringcell(scell, element)
% findindex4stringcell is to find the index of one element in a string cell
% scell is a cell with every element to be a string
% -wsun, 02/24/2012. 


for k=1:length(scell)
    if strcmp(scell{k}, element);
        ind = k ;
        return ;
    end
end

ind = -1 ;
%error('the string element you are searching is not in the cell') ;





