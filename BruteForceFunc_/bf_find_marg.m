%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ***************************************
function marg = bf_find_marg(model,jp) ;

% model has domain, sizes
% model.node_names
% model.domain
% model.sizes

if nargin ~= 2, error('Function has to have exactly 2 arguments'); end

node_names = model.node_names ;
N = length(node_names) ;

marg = cell(1,N) ;

for i=1:length(node_names) 
    marg{i} = bf_find_currProb(model,jp,node_names(i)) ;
end
