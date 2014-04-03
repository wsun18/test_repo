function state_range = DAC_VP_transfer_state_to_range(VP_Nodes, vp_states) 
% This function is to transfer states of VP nodes into corresponding range.
% -wsun, Feb.6, 2014.

for k=1:length(VP_Nodes)
    vpnode = VP_Nodes{k} ;
    vpstate = vp_states(k) ;
    
    if vpstate > length(vpnode.cutpoints)
        state_range = [vpnode.cutpoints(end), vpnode.max] ;
    else
        if vpstate == 1
            tr1 = vpnode.min ;
        else
            tr1 = vpnode.cutpoints(vpstate - 1) ;
        end
        tr2 = vpnode.cutpoints(vpstate) ;
        state_range(k,:) = [tr1, tr2] ;
    end
    
end