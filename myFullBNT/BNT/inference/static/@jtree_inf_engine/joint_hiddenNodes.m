function joint = joint_hiddenNodes(engine)
% joint_hiddenNode computes the joint distribution of all hidden nodes in a
% Bayesnet
% - wsun 11/1/2011

% joint = product of all cliques potentials / product of all separators
% potentials

clpot = engine.clpot ;
seppot = engine.seppot ;



order = engine.postorder ;
order_parents = engine.postorder_parents ;


%mysetdiff([1 3],[1 2]) ;

for i=order
    curr_clq = i ;
    curr_joint = reshape(clpot{curr_clq}.T, prod(clpot{curr_clq}.sizes),1) ;
    curr_domain = clpot{curr_clq}.domain ;
    curr_sizes = clpot{curr_clq}.sizes ;
    curr_cc = full_combination_new(curr_sizes) ;
    
    for j=order_parents{i}
        add_domain = mysetdiff(clpot{j}.domain, curr_domain) ;       
        new_domain = [curr_domain add_domain] ;
        add_sizes = clpot{j}.sizes(find_equiv_posns(add_domain, clpot{j}.domain)) ;
        new_sizes = [curr_sizes add_sizes] ;
        next_cc = full_combination_new(clpot{j}.sizes) ;
        joint_cc = full_combination_new(new_sizes) ;
        next_joint = reshape(clpot{j}.T, prod(clpot{j}.sizes),1) ;
        
        curr_seppot = seppot{j,curr_clq} ;
        sep_joint = reshape(curr_seppot.T, prod(curr_seppot.sizes),1) ;
        sep_cc = full_combination_new(curr_seppot.sizes) ;
        
        for k=1:size(joint_cc,1)
            ind_curr_cc = joint_cc(k,find_equiv_posns(curr_domain, new_domain)) ; 
            ind_next_cc = joint_cc(k,find_equiv_posns(clpot{j}.domain,new_domain)) ;
            ind_sep_cc = joint_cc(k,find_equiv_posns(curr_seppot.domain,new_domain)) ;
            new_joint(k) = curr_joint(find_rowIndex(ind_curr_cc, curr_cc)) * ...
                next_joint(find_rowIndex(ind_next_cc,next_cc)) / ...
                sep_joint(find_rowIndex(ind_sep_cc,sep_cc)) ;        
        end
        
        clpot{j}.domain = new_domain ;
        clpot{j}.sizes = new_sizes ;        
        clpot{j}.T = reshape(new_joint,new_sizes) ;
    end
end

joint.domain = new_domain ;
joint.sizes = new_sizes ;
joint.T = new_joint ;
joint.cc = joint_cc ;


    






