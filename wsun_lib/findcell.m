function ind = find_rowIndex(r,m)
% find_rowIndex(m) is to find the row index number for a 2-dim matrix m,
% where r is the row vector for which we are looking for its index, r has
% to match one of row exactly in m, otherwise an error message will pop
% out.
% Nov. 3, 2011


for k=1:size(m,1)
    if isequal(r, m(k,:));
        ind = k ;
        return ;
    end
end

error('the row you are searching is not in the matrix') ;





