
% Nov.30, 2006

function bel = compute_bel_hybrid_gmm(msg_type, pi, lambda) 
 % Compute the belief based on 'pi' and 'lambda' values of a node.
 % For a continuous node, 
 %   - pi: mu and Sigma; lambda: precision and info_state.
 % For a discrete node, 
 %   - pi and lambda are both vectors
 
 switch msg_type
     case 'd'
         bel = normalise(pi .* lambda);  
     case 'gm'
         bel = compute_bel_gmm(pi,lambda);
     otherwise
         error('wrong msg_type')
 end
 
 