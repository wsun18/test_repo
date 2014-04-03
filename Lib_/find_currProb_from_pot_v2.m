function cprob = find_currProb_from_pot_v2(engine, Targ, targ, Assm, assm)
% This is to compute the current probability on the particular state (targ)
% for Targ, given Assm=assm
% Since we have the constraint of having both the target variable and the
% conditioning variables in the same clique, so we should be able to find
% at least one clique to contain all of these variables.
% --wsun, 12/12/2012.

if nargin <= 3, Assm = {}; assm=[]; end

bnet = bnet_from_engine(engine) ; 
clpot = clpot_from_engine(engine) ;
indTarg = findindex4stringcell(bnet.node_names, Targ) ;
indAssm = [] ;
if ~isempty(Assm)    
    for k=1:length(Assm)
        indAssm = [indAssm findindex4stringcell(bnet.node_names, Assm{k})] ;
    end   
end
vargroup = [indTarg indAssm] ;
c=0;
for k=1:length(clpot)
    if mysubset(vargroup,clpot{k}.domain)
        c = k;
    end    
end
assert(c>0) ;
%c = clq_containing_nodes(engine, Targind);
%c = 1 ;
model.node_names = bnet.node_names(clpot{c}.domain) ;
model.sizes = bnet.node_sizes(clpot{c}.domain) ;

jp = clpot{c}.T(:) ;
cProb = bf_find_currProb(model,jp,Targ,Assm,assm) ;

cprob = cProb(targ) ;
