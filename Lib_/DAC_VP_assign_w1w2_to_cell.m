
function w = DAC_assign_w1w2_to_cell(VP_Targ,targ_state,delta,targ_range,ref_range)
% This function is to assign the right asset to the state
% Feb., 6th, 2014.

if nargin < 5, ref_range=[]; end

w = 0 ;

if targ_state > length(VP_Targ.cutpoints)
    state_range = [VP_Targ.cutpoints(end), VP_Targ.max] ;
else
    if targ_state == 1
        tr1 = VP_Targ.min ;
    else
        tr1 = VP_Targ.cutpoints(targ_state - 1) ;
    end
    tr2 = VP_Targ.cutpoints(targ_state) ;
    state_range = [tr1, tr2] ;
end

if DAC_mysubintval(state_range, targ_range)
    w = delta(1); 
else
    if ~isempty(ref_range)
        if DAC_mysubintval(state_range, ref_range)
            w = delta(2) ;
        end
    else
        w = delta(2) ;
    end
end