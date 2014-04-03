function curr_ab = DAC_VP_update_block_by_new_cutpoints(curr_ab, ind_VP, VP_old_cutpoints, VP_new_cutpoints)
% This function is to update an asset block when a VP node in the block
% obtains new cutpoints.
% -wsun, 02/07/2014.

c_dom = curr_ab.dom ;
c_T = curr_ab.T ;
c_sizes = curr_ab.var_sizes ;

old_cutpoints = VP_old_cutpoints ;

posTarg = find_equiv_posns(ind_VP, c_dom) ;
posOther = find(c_dom ~= ind_VP) ;

assert(c_sizes(posTarg) == length(old_cutpoints) + 1) ;

% update 'c_sizes' with new size of 'VP_Targ'
old_sizes = c_sizes ;

T_sz = length(VP_new_cutpoints) + 1 ;
c_sizes(posTarg) = T_sz ;

if length(c_sizes)>1
    new_T = zeros(c_sizes) ;
else
    new_T = zeros(c_sizes,1) ;
end

h_cc = full_combination_new(c_sizes) ;
noi = size(h_cc,1); % number of instances

for j=1:noi
    instance = h_cc(j,:) ;
    other_state = instance(posOther) ; % states for all other questions than VP_Targ  
    new_targ_state = instance(posTarg) ; 
    old_targ_state = DAC_find_oldstate_from_new(new_targ_state,...
        VP_new_cutpoints, VP_old_cutpoints) ;

    old_inst(posOther) = other_state ;
    old_inst(posTarg) = old_targ_state ;

    new_T(j) = c_T(find_linearIndex_from_mat(old_sizes, old_inst)) ;            
end  

curr_ab.T = new_T ;
curr_ab.var_sizes = c_sizes ;