
function ind = find_linearIndex_from_mat(sz, pv)
% find the linear index for a multi-dimension matrix with size 'sz'
% pv is the position vector, example: [2 1] means the postion (2,1) 
% for a 2-dim matrix


ind = pv(1) ; 
for k=2:length(pv)
    tp = (pv(k) - 1) * prod(sz(1:k-1)) ;    
    ind = ind + tp ;
end
