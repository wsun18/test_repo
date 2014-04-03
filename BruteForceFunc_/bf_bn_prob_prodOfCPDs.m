function jp = bnbf_prob_productOfCPDs(engine)
% This is to calculate the joint probability by the product of CPDs in a
% BN, which is not always the true joint probability unfortunately. 

bnet = bnet_from_engine(engine) ;

ns = bnet.node_sizes ;
h_cc = full_combination_new(ns) ;

noi = size(h_cc,1); % number of instances
for i=1:noi
    instance = h_cc(i,:);        
    cpt = CPD_to_CPT(bnet.CPD{1}) ;
    p = cpt(instance(1)) ;
    for j=2:length(instance)
        cpt = CPD_to_CPT(bnet.CPD{j}) ;
        sz = size(cpt) ;
        indmat = instance([bnet.parents{j} j]) ;        
        pos = find_linearIndex_from_mat(sz,indmat) ;
        p = p*cpt(pos) ;
    end
    jp(i) = p ;    
end

jp = [h_cc jp'] ;