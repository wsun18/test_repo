function lk = evid_likelihood(engine, evidence, given_node)
% compute the likelihood of evidence, 
% might be given some specific node/nodes included in the evidence.
% Feb.16, 2007

if isemptycell(evidence)
    disp('+++++ Warning: no evidence specified. likelihood = 0') ; 
    lk = 0 ;
    return ;
end

if nargin < 3, given_node =[] ; end

bnet = bnet_from_engine(engine);
N = length(bnet.dag) ;

observed = find(~isemptycell(evidence)) ;
original_evidence = evidence ;  % save the original evidence
evidence = cell(1,N) ;
evidence(given_node) = original_evidence(given_node) ;
observed = mysetdiff(observed, given_node) ;

w=1 ;
for k=observed    
    leaf = k ;
    [engine, ll] = enter_evidence(engine, evidence) ;        
    leaf_dist = marginal_nodes(engine, leaf) ;
    leaf_obs =  original_evidence{k} ; 
    if intersect(k, bnet.dnodes)
        w = w * leaf_dist.T(leaf_obs) ;
    else
        w = w * normpdf(leaf_obs, leaf_dist.mu, sqrt(leaf_dist.Sigma)) ;
    end
    evidence{k} = leaf_obs ;
end

lk = w ;
