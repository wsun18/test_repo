function p = log_lik_hidden(engine, hidden_states, evidence)
% calculate the joint probability of all hidden nodes
% at one particular joint states
% -wsun, 11/9/2011

hidden = find(isemptycell(evidence));
instance = hidden_states ;

p = 1;
tp_evids = evidence ;
for j=hidden
    [engine_jtree, ll] = enter_evidence(engine, tp_evids) ;
    marg = marginal_nodes(engine, j) ;    
    p = p * marg.T(instance(j)) ; 
    tp_evids{j} = instance(j) ;        
end
    

