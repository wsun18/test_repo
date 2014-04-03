function pot = updateCPD_from_clpot(pot, node, ps, par_sz)
% Update CPD of 'node' from its assigned clique potentials, in which
% parents of 'node' are included.


if ~mysubset(ps, pot.domain)
    error('Parents of the node have to be a subset of assigned clique domain') ;                
end

marg = marginal_nodes_from_clpot(pot, [ps node]) ;

hcc = full_combination_new(par_sz) ;
for j=1:size(hcc,1)
    instance = hcc(j,:) ;    
    tp_clpot = enter_evidence_clpot(pot,ps,instance) ;
    marg = marginal_nodes_from_clpot(tp_clpot, k) ;
    tempT(j,:) = marg.T' ;
end  

CPD_sz = ns([parent k]) ;
tempT = reshape(tempT, CPD_sz) ;




observed = find(~isemptycell(evidence)) ;

if isempty(myintersect(observed, pot.domain))
    error('Observed variables have to be in the clique') ;
end

T = pot.T




[pot.T, lik] = normalise(pot.T);
loglik = log(lik + (lik==0)*eps);

      
