function cprob = find_currProb(engine, Targ, targ, Assm, assm)

% bnet = bnet_from_engine(engine) ; 
% evids = cell(1,length(bnet.dag)) ;
% for k=1:length(assm)
%     indassm(k) = findindex4stringcell(bnet.node_names, Assm{k}) ;
%     evids{indassm(k)} = assm(k) ;
% end
% indtarg = findindex4stringcell(bnet.node_names, Targ) ;
% engine = enter_evidence(engine, evids) ;
% margTarg = marginal_nodes(engine, indtarg) ;
% cprob = margTarg.T(targ) ;

% new version to compute the current conditional probability
% P(Targ=targ|Assm=assm) from potentials only. -wsun, 4/2/2012
bnet = bnet_from_engine(engine) ; 
evids = cell(1,length(bnet.dag)) ;
for k=1:length(assm)
    indassm(k) = findindex4stringcell(bnet.node_names, Assm{k}) ;
    evids{indassm(k)} = assm(k) ;
end
indtarg = findindex4stringcell(bnet.node_names, Targ) ;
margTarg = marginal_nodes_from_pot(engine, indtarg, evids);
cprob = margTarg.T(targ) ;