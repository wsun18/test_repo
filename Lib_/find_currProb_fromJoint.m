%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ***************************************
function cprob = find_currProb_fromJoint(model,jp,Targ,Assm,assm) 

% model has domain, sizes
% model.node_names
% model.domain
% model.sizes

if nargin == 0, error('It has to have arguments'); end
if nargin < 4, Assm = {}; assm=[]; end

node_names = model.node_names ;
ns = model.sizes ;
dom = model.domain ;

if ~isempty(Assm)
    indAssm = [] ;
    for k=1:length(Assm)
        indAssm = [indAssm findindex4stringcell(node_names, Assm{k})] ;
    end
end
indTarg = findindex4stringcell(node_names, Targ);

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances
cprob = zeros(ns(indTarg),1) ;
for i=1:noi
    instance = h_cc(i,:);   
    if ~isempty(Assm)
        if isequal(instance(indAssm),assm)
            targ_state = instance(indTarg) ;
            cprob(targ_state) = cprob(targ_state) + jp(i) ;
        end
    else
        targ_state = instance(indTarg) ;
        cprob(targ_state) = cprob(targ_state) + jp(i) ;
    end   
end

% normalization
cprob = cprob/sum(cprob) ;

