
function [pj h_cc hidden] = brute_force_joint(engine, evidence)
% find joint distribution for all hidden variables in a compiled Bayesian
% networks - compiled means that Junction tree engine has been run for this
% BN given evidence.
% Only works for pure discrete BNs.
% h_cc is the full list of joint states for all hidden variables
% -wsun, Nov.30, 2011

bnet = bnet_from_engine(engine) ;

hidden = find(isemptycell(evidence)) ;
hsizes = bnet.node_sizes(hidden) ;
h_cc = full_combination_new(hsizes) ;

noi = size(h_cc,1); % number of instances
for i=1:noi
    tp_evids = evidence ;
    instance = h_cc(i,:);    
    p = 1 ;
    for j=hidden
        [engine, ll] = enter_evidence(engine, tp_evids) ;
        marg = marginal_nodes(engine, j) ;    
        p = p * marg.T(instance(find_equiv_posns(j,hidden))) ; 
        tp_evids{j} = instance(find_equiv_posns(j,hidden)) ;        
    end
    pj(i) = p ;    
end
