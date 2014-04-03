function p = compute_joint_from_CPD(CPD,parents,instance) 
%% compute_joint_from_CPD is to calculate the joint probability over all
%% variables with their conditional probabilities encoded in CPDs. 
%% instance contains all instantiated values of variables


curr_CPD = CPD{1} ;
CPT = CPD_to_CPT(curr_CPD) ;
domain = 1 ;
state = instance(domain) ;
p =  CPT(state) ;

for k=2:length(CPD)
    curr_CPD = CPD{k} ;    
    CPT = CPD_to_CPT(curr_CPD) ;
    domain = [parents{k} k] ;
    state = instance(domain) ;
    pos = find_linearIndex_from_mat(size(CPT), state) ;
    p =  p * CPT(pos) ;
end

