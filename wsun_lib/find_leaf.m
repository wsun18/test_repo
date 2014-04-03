
function v = find_leaf(sqmat)
% sqmat is a square matrix
% find_leaf is to find the leaf node in a Bayesian network
% return v is a vector including all leaf nodes.

j=1 ;
for i=1:length(sqmat)
    if sum(sqmat(i,:)) == 0
        v(j) = i ;
        j = j+1 ;
    end
end