function joint = joint_hiddenNodes(engine)
% joint_hiddenNode computes the joint distribution of all hidden nodes in a
% Bayesnet
% - wsun 11/1/2011

% joint = product of all cliques potentials / product of all separators
% potentials

clpot = engine.clpot ;
seppot = engine.seppot ;


% N = length(clpot) ;
% sep_cc = full_combination_new([N N]);
% seppot = reshape(seppot,N*N,1) ;

% i = find(~cellfun('isempty',seppot)); 
order = engine.postorder ;

curr_clq = order(1) ;
curr_joint = reshape(clpot{curr_clq}.T, prod(clpot{curr_clq}.sizes),1) ;
curr_domain = clpot{curr_clq}.domain ;
curr_sizes = clpot{curr_clq}.sizes ;
curr_cc = full_combination_new(curr_sizes) ;
%mysetdiff([1 3],[1 2]) ;

for i=order(2:end)
    add_domain = mysetdiff(clpot{i}.domain, curr_domain) ;       
    new_domain = [curr_domain add_domain] ;
    add_sizes = clpot{i}.sizes(find_equiv_posns(add_domain, clpot{i}.domain)) ;
    new_sizes = [curr_sizes add_sizes] ;
    add_cc = full_combination_new(clpot{i}.sizes) ;
    joint_cc = full_combination_new(new_sizes) ;
    add_joint = reshape(clpot{i}.T, prod(clpot{i}.sizes),1) ;
        
    curr_seppot = seppot{i,curr_clq} ;
    sep_joint = reshape(curr_seppot.T, prod(curr_seppot.sizes),1) ;
    sep_cc = full_combination_new(curr_seppot.sizes) ;
    
    for j=1:size(joint_cc,1)
        ind_curr_cc = joint_cc(j,curr_domain) ; 
        ind_add_cc = joint_cc(j,clpot{i}.domain) ;
        ind_sep_cc = joint_cc(j,curr_seppot.domain) ;
        new_joint(j) = curr_joint(find_rowIndex(ind_curr_cc, curr_cc)) * ...
            add_joint(find_rowIndex(ind_add_cc,add_cc)) / ...
            sep_joint(find_rowIndex(ind_sep_cc,sep_cc)) ;        
    end
    
    curr_joint = new_joint ;
    curr_domain = new_domain ;    
    curr_sizes = new_sizes ;
    curr_cc = joint_cc ;
    
    curr_clq = i ;
end

joint.domain = curr_domain ;
joint.sizes = curr_sizes ;
joint.T = curr_joint ;
joint.cc = curr_cc ;


    






