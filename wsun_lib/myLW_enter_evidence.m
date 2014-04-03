
function [samples weights] = myLW_enter_evidence(bnet, evidence, nsp)
% compute belief for every hidden node using likelihood weighting, return
% mu and Sigma as the fields. 
% assume all nodes are continuous with size 1.
% written on Jan.29, 2007

if nargin < 3, nsp=500 ; end

N = length(bnet.dag) ;
bel = cell(1, N) ;

hidden = find(isemptycell(evidence)); 
observed = ~isemptycell(evidence);

samples = cell(nsp, N) ;
weights = zeros(1, nsp) ;

original_evidence = evidence ;

for i=1:nsp
    %i
    evidence = original_evidence ;
    w = 1 ;
    for node=bnet.order(:)'                  
        ps = bnet.parents{node} ;        
        if observed(node)
            lk = obs_likelihood(bnet.CPD{node}, evidence(node), evidence(ps)) ;
            w = w*lk ;
        else
            xsp = sample_node(bnet.CPD{node}, evidence(ps)) ;
            evidence{node} = xsp ;            
        end            
    end
    samples(i,:) = evidence    ;
    weights(i) = w ;
end


%%%%%%