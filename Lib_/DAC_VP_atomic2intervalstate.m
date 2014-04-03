function interval_state = DAC_VP_atomic2intervalstate(VP_Node, atomic) 
% This function is to transfer VP-node's atomic states to its interval state.
% -wsun, March 31, 2014.


cutpoints = VP_Node.cutpoints ;
minpoint = VP_Node.min ;
maxpoint = VP_Node.max ;

assert(~isempty(cutpoints)) ;
assert(atomic >= minpoint) ;
assert(atomic <= maxpoint) ;

for k=1:length(cutpoints)
    tp = cutpoints(k) ;
    if atomic <= tp
        interval_state = k ;
        return ;
    end    
end

interval_state = k+1 ;

