function tw = mycheck_treewidth(bnet)
% To check the tree width of a BN
% The input bnet must be a well established bnet 
% Dec. 6, 2012

engine = jtree_inf_engine(bnet);

clqs = cliques_from_engine(engine) ;
for i=1:length(clqs)    
    clqsz(i) = length(clqs{i}) ;
end
tw = max(clqsz) - 1 ;





