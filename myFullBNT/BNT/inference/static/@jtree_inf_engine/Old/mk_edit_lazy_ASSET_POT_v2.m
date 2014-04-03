function [engine asset_part] = mk_edit_lazy_ASSET_POT_v2(engine, Targ, targ, tprob, asset, Assm, assm) 
% This function mk_edit is to update the probabilities and assets by
% cliques and separators for the original network given an edit

% updated to use potential as the atom unit for representing probabilities,
% no CPD updating any more. --- wsun, 12/12/2012
% updated to use asset directly for computations. 8/3/12, wsun.
% provided choice of log base values (2 or natural log). 9/11/12, wsun.

if nargin == 0, error('It has to have arguments'); end
if nargin <= 5, Assm = {}; assm=[]; end

[dummynet dummy_parents_sorted] = mk_dummynet(engine, Targ, targ, tprob, Assm, assm) ;
% print out CPT of dummy node
dummy = length(dummynet.dag) ;
dummy_cpd = dummynet.CPD{dummy} ; 
dummy_cpt = CPD_to_CPT(dummy_cpd) ;

bnet = bnet_from_engine(engine) ;
% dag = bnet.dag ;
% N = length(dag) ;
node_names = bnet.node_names ;

% clpot = clpot_from_engine(engine) ;
% seppot = seppot_from_engine(engine) ;
clpot = engine.clpot ;
seppot = engine.seppot  ;

% find the clique that contains both Targ and Assm. It is possible to have
% more than one cliques that contain them, but finding one is good enough.
for k=1:length(clpot)
    if mysubset(dummy_parents_sorted, clpot{k}.domain)
        cid = k ;
    end    
end

% update the potential for the clique (found above) given the edit
model.node_names = node_names(clpot{cid}.domain) ;
model.sizes = clpot{cid}.sizes ;
old_T = clpot{cid}.T ;
jp_before = clpot{cid}.T(:) ;

cProb = bf_find_currProb(model,jp_before,Targ,Assm,assm) ;
tProb = proportional_adjust_prob(cProb,targ,tprob) ;
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

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dummynet dummy_parents_sorted] = mk_dummynet(engine, Targ, targ, tprob, Assm, assm)
% mk_dummynet builds a network with a dummy node to be the child of set of
% assumed variables and the target variable.
% Assm is the set of assumed variables, while assm is the set of
% corresponding values
% Targ is the target variable the user likes to make an edit, on its state
% 'targ'
% tprob is the probability P(Targ=targ|Assm=assm)
% -wsun, Feb. 23, 2012

%if nargin == 0, error('It has to have arguments'); end
%if nargin <= 4, Assm = {}; end

% args = varargin;
% nargs = length(args);
% for i=1:2:nargs
%   switch args{i},
%    case 'Assm',    Assm = args{i+1}; 
%    otherwise,  
%     error(['invalid argument name ' args{i}]);       
%   end
% end

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
dummy_parent_names = node_names(dummy_parents_sorted) ;

% adding dummy node to the original net
node_names{end+1} = 'dummy' ;
dummy = N + 1 ;
dag(dummy,:) = 0 ; dag(:,dummy) = 0 ;
dag(dummy_parents_sorted, dummy) = 1 ;

dnodes = bnet.dnodes ;
dnodes(end+1) = dummy ;
ns = bnet.node_sizes ;
ns(dummy) = 2 ; % dummy node always has two states and always is observed in state one.

dummynet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);


% specify the CPT for dummy node
% P(X)L(X) = Q(X)  ==> L(X) = Q(X)/P(X)
% X is the set of Assm and Targ, including all combination of the joint
% space
% P(Assm, Targ) = P(Targ|Assm)P(Assm)
% Q(Assm, Targ) = Q(Targ|Assm)Q(Assm)
% Note that Q(Assm)=P(Assm), so: 
% Q(Assm, Targ) / P(Assm, Targ) = Q(Targ|Assm) / P(Targ|Assm)
% But only Q(Targ=targ|Assm=assm) is the one
% being edited, and then Q(Targ~=targ|Assm=assm) are changing accordingly.
% All of other Qs equal to Ps

% tprob = Q(Targ=targ|Assm=assm), then Q(Targ~=targ|Assm=assm) will 
% change propositionally and accordingly

dummynet.CPD(1:end-1) = bnet.CPD(:) ; %%%% bnet.CPD have been updated from engine
ns_dummyparent = ns(dummy_parents_sorted) ;
cc = full_combination_new(ns_dummyparent) ;
cc(:,length(dummy_parents_sorted)+1) = 1 ; % initializing

evids = cell(1, N) ;
if ~isempty(Assm)
    for k=1:length(Assm)
        evids{findindex4stringcell(node_names, Assm{k})} = assm(k) ;
    end
end
% [engine, ll] = enter_evidence(engine, evids) ;
% marg = marginal_nodes(engine, findindex4stringcell(node_names, Targ)) ;
indtarg = findindex4stringcell(bnet.node_names, Targ) ;
marg = marginal_nodes_from_pot(engine, indtarg, evids);
P_Targ = marg.T ;% This is P(Targ|Assm=assm)

Targ_ns = ns(findindex4stringcell(node_names, Targ)) ;
Q_Targ = zeros(Targ_ns,1) ; %This is Q(Targ|Assm=assm)
nnm = 1 - P_Targ(targ) ; % normalization constant for normalizing probabilities on other states
for k=1:Targ_ns
    if k == targ
        Q_Targ(targ) = tprob ;
    else        
        Q_Targ(k) = (1-tprob)*P_Targ(k)/nnm ;
    end
end

% AssmIndex is the index of Assm in dummy_parent_sorted
for k=1:length(Assm)
    AssmIndex(k) = findindex4stringcell(dummy_parent_names, Assm{k}) ;
end
% TargIndex is the index of Targ in dummy_parent_sorted (Targ has only one
% variable
TargIndex = findindex4stringcell(dummy_parent_names, Targ) ;

% update Q-P-ratio for corresponding states
for k = 1:size(cc,1) 
    %instance = cc(k,:) ;
    if ~isempty(assm)
        if myisequal(cc(k, AssmIndex), assm)  
            Targ_state = cc(k, TargIndex) ;
            cc(k, end) = Q_Targ(Targ_state) / P_Targ(Targ_state) ;
        end
    else
        Targ_state = cc(k, TargIndex) ;
        cc(k, end) = Q_Targ(Targ_state) / P_Targ(Targ_state) ;
    end        
end

dummy_cpt = cc(:,end)' ;
dummy_cpt = dummy_cpt/sum(dummy_cpt) ;
dummy_cpt = [dummy_cpt 1-dummy_cpt] ;

dummynet.CPD{dummy} = tabular_CPD(dummynet, dummy, dummy_cpt) ;



%%%%

