
function pv = find_matposn_from_linearIndex(lii, sz)
% find the right matrix index from the given linear index, for a 
% multi-dimensional matrix with size 'sz'
% pv is the position vector, example: [2 1] means the postion (2,1) 
% for a 2-dim matrix, corresponding to the linear index 2.

pv = ones(sz) ;

if lii <= sz(1)
    pv(1) = lii ;
    return;
end
    
for k=2:length(sz)
    tp = prod(sz(1:k-1)) ;    
    if lii < tp
        dif = lii - tp ;
        pv(k) = dif + 1 ;
        return ;
    end    
end
