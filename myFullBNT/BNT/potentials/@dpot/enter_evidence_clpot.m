function pot = enter_evidence_clpot(pot, ps, instance)
% Update potential by absorbing evidence. Observed variables are assumed to
% be in the clique

observed = find(~isemptycell(evidence)) ;

if isempty(myintersect(observed, pot.domain))
    error('Observed variables have to be in the clique') ;
end

T = pot.T




[pot.T, lik] = normalise(pot.T);
loglik = log(lik + (lik==0)*eps);

      
