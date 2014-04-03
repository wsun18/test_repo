function [engine asset_part] = mk_edit_lazy_ASSET_POT(engine, Targ, targ, tprob, asset, Assm, assm, userDist) 
% This function mk_edit is to update the probabilities and assets by
% cliques and separators for the original network given an edit

% UPDATE History:
% ----------------------
% wsun, 3/26/2013: I like to provide options to let user specifys the
% entire target distribution, as well as the default option that providing
% proportinally adjusted probabilities for states other than the target
% state.

% updated to use potential as the atom unit for representing probabilities,
% no CPD updating any more. --- wsun, 12/12/2012

% provided choice of log base values (2 or natural log). 9/11/12, wsun.

% updated to use asset directly for computations. 8/3/12, wsun.
% -------------------------


if nargin == 0, error('It has to have arguments'); end
if nargin <= 5, Assm = {}; assm=[]; end
% wsun, 3/26/2013: provide the option for user to specify the entire target
% distribution
if nargin <= 7, userDist = [] ; end 

bnet = bnet_from_engine(engine) ;
dag = bnet.dag ;
N = length(dag) ;

if ~isempty(Assm)
    dummy_parent_names = [Assm, Targ] ;
else 
    dummy_parent_names = Targ ;
end

dummy_parents = [] ;
node_names = bnet.node_names ;
for k=1:length(dummy_parent_names)
    dummy_parents = [dummy_parents findindex4stringcell(node_names, dummy_parent_names{k})] ;
end
dummy_parents_sorted = sort(dummy_parents) ;
%dummy_parent_names = node_names(dummy_parents_sorted) ;

% clpot = clpot_from_engine(engine) ;
% seppot = seppot_from_engine(engine) ;
clpot = engine.clpot ;
seppot = engine.seppot  ;

% find the clique that contains both Targ and Assm. It is possible to have
% more than one cliques that contain them, but finding one is good enough.
for k=1:length(clpot)
    if mysubset(dummy_parents_sorted, clpot{k}.domain)
        cid = k ;
        break ; % once finding one right clique, jump out the loop.
    end    
end

% update the potential for the clique (found above) given the edit
model.node_names = node_names(clpot{cid}.domain) ;
model.sizes = clpot{cid}.sizes ;
old_T = clpot{cid}.T ;
jp_before = clpot{cid}.T(:) ;

cProb = bf_find_currProb(model,jp_before,Targ,Assm,assm) ;
% wsun, 3/26/2013: I like to provide options to let user specifys the
% entire target distribution, as well as the default option that providing
% proportinally adjusted probabilities for states other than the target
% state.
if ~isempty(userDist)
    tProb = userDist ;
else
    tProb = proportional_adjust_prob(cProb,targ,tprob) ;
end
jp_after = bf_prob_update(model,jp_before,Targ,tProb,Assm,assm) ;

% new updated potential for the clique
clpot{cid}.T = reshape(jp_after,clpot{cid}.sizes) ;
new_T = clpot{cid}.T ;

% propagate to update all cliques/separators potentials. 
[clpot, seppot] = collect_evidence(engine, clpot, seppot);
[clpot, seppot] = distribute_evidence(engine, clpot, seppot);

% Normalizing clique potentials
for i=1:length(clpot)
    [clpot{i}, ll(i)] = normalize_pot(clpot{i});
end

% Normalizing separator potentials, added on 11/7/2011, -wsun. 
% After adding this part of code, calculating the joint by (product of
% cliques potentials) / (product of separators potentials) returned correct
% results. :)
for n=engine.postorder  
    for p=engine.postorder_parents{n}
        seppot{p,n} = normalize_pot(seppot{p,n});
    end
end   
% set_fields(engine,'clpot',clpot) ;
% set_fields(engine,'seppot',seppot) ;
engine.clpot = clpot ;
engine.seppot = seppot ;

% clpot{1}.T
% clpot{2}.T


pc_ratio{cid} = new_T ./ old_T ;

asset_part = asset ;
b = asset.b ;
log_base = asset.logbase ;
switch(log_base)
    case 2
        asset_part.clq{cid}.T = (asset.clq{cid}.T) + b*log2(pc_ratio{cid}) ;        
    case exp(1)
        asset_part.clq{cid}.T = (asset.clq{cid}.T) + b*log(pc_ratio{cid}) ;        
    otherwise
        error('Please specify log base value');
end

    
