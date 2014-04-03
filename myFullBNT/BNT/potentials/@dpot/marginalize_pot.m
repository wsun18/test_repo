% function smallpot = marginalize_pot(bigpot, onto, maximize, minimize)
function smallpot = marginalize_pot(bigpot, onto, moption)
% MARGINALIZE_POT Marginalize a dpot onto a smaller domain.
% smallpot = marginalize_pot(bigpot, onto, maximize)
%
% 'onto' must be in ascending order.

%if nargin < 3, maximize = 0; end
% modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
% 'moption' means marginization option. 
% -wsun
if nargin < 3, moption = 'sum'; end

ns = zeros(1, max(bigpot.domain));
ns(bigpot.domain) = bigpot.sizes;
%assert(isequal(bigpot.sizes, mysize(bigpot.T))); % may fail if there are trailing dimensions of size 1
if issparse(bigpot.T)
   smallT = marg_sparse_table(bigpot.T, bigpot.domain, bigpot.sizes, onto, maximize);
else 
   %smallT = marg_table(bigpot.T, bigpot.domain, bigpot.sizes, onto, maximize);
   smallT = marg_table(bigpot.T, bigpot.domain, bigpot.sizes, onto, moption);
end
%-wsun, 7/4/13, need to make sure the table agrees to the size.
if length(onto) == 1
    smallpot = dpot(onto, ns(onto), smallT);
    return ;
end
smallT = reshape(smallT(:),ns(onto)) ; 
smallpot = dpot(onto, ns(onto), smallT);
