
function marg = myLW_marginal(bnet, samp, wt, node)
% compute gaussian marginal of hidden node
% written on Jan.25, 2007

%[sp wt] = get_samples(engine) ;

wt = wt/sum(wt) ; % normalization

%i = find_index(node, hidden) ;

if isempty(i)
    error('Error: this node is observed, no marginal') ;
end

%samp = cat(1, sp{:,i}) ;
%samp = sp(:,i) ;
if intersect(node, bnet.cnodes)
    marg.mu = samp' * wt' ;
    marg.Sigma = (samp' - marg.mu).^2 * wt' ;
else
    T = zeros(bnet.node_sizes(node),1) ;
    for k=1:length(samp)        
        T(samp(k)) = T(samp(k)) + wt(k) ;
    end
    marg.T = T ;
end

% %%%%%%%%+++++++++++++++++++++++
% function j = find_index(i, vt) 
%  % i is one element in vt which is a vector
%  % return j which is the index of i in vt.
%  % assume there is only one i in vt, no repeat.
%  % example is the best explanation
%  % i=3, vt=[2 3 5]
%  % then j=2.
%  
%  n=1 ; 
%  for k=1:length(vt)
%      if i == vt(k)
%          j(n) = k ;
%          n = n+1 ;
%      end     
%  end
%  
%  if n==1
%      j = [] ; % if i is not in vt, j=[].
%  end
