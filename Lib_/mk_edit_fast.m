function [engine asset_part] = mk_edit_fast(engine, Targ, targ, tprob, asset, Assm, assm) 
% This function mk_edit is to update the probabilities and assets by
% cliques and separators for the original network given an edit

if nargin == 0, error('It has to have arguments'); end
if nargin <= 5, Assm = {}; assm=[]; end

t0 = cputime ;
[dummynet dummy_parents_sorted] = mk_dummynet(engine, Targ, targ, tprob, Assm, assm) ;

% propagate and update probabilities for this new network with the dummy node
engine_temp = jtree_inf_engine(dummynet) ;
dummy = length(dummynet.dag) ;
evids = cell(1, dummy) ;
evids{dummy} = 1 ; % dummy node is always observed at the first state.
[engine_temp, ll] = enter_evidence(engine_temp, evids) ; 
locktime = cputime - t0 ;
fprintf('* System lock time for the trade is %10.6f cputime \n\n', locktime) ;

% print out CPT of dummy node
dummy_cpd = dummynet.CPD{dummy} ; 
dummy_cpt = CPD_to_CPT(dummy_cpd) 


% new_clpot = clpot_from_engine(engine_temp) ;
% new_seppot = seppot_from_engine(engine_temp) ;

% update all CPDs for nodes in the original network
bnet = bnet_from_engine(engine) ;
clpot = clpot_from_engine(engine) ;
seppot = seppot_from_engine(engine) ;
ns = bnet.node_sizes ;
for k=1:length(bnet.CPD) 
    CPD = bnet.CPD{k} ;
    parent = bnet.parents{k} ;
    if ~isempty(parent)
       par_sz = ns(parent) ;
       hcc = full_combination_new(par_sz) ;
       for j=1:size(hcc,1)
          instance = hcc(j,:) ;
          evids(parent) = num2cell(instance) ;
          engine_temp = enter_evidence(engine_temp, evids) ;
          marg = marginal_nodes(engine_temp, k) ;
          tempT(j,:) = marg.T' ;
       end  
       CPD_sz = ns([parent k]) ;
       tempT = reshape(tempT, CPD_sz) ;
       bnet.CPD{k} = set_fields(CPD, 'userCPT', tempT) ;    
       tempT = [] ;
    else
        marg = marginal_nodes(engine_temp, k) ;
        tempT = marg.T ;
        bnet.CPD{k} = set_fields(CPD, 'userCPT', tempT) ;
        tempT = [] ;
    end    
end

engine = jtree_inf_engine(bnet) ;
evids = cell(1,length(bnet.dag)) ;
engine = enter_evidence(engine,evids) ;
new_clpot = clpot_from_engine(engine) ;
new_seppot = seppot_from_engine(engine) ;

for k=1:length(clpot) 
    domain = clpot{k}.domain ;
    if mysubset(dummy_parents_sorted, domain)
        cid = k ;  % cid is the clique number that represent the affected clique by edit.
        pc_ratio{cid} = (new_clpot{k}.T) ./ (clpot{k}.T) ; % probability ratio on cliques     
    end
    %pc_ratio{k} = (new_clpot{k}.T) ./ (clpot{k}.T) ; % probability ratio on cliques     
end
    
% sepmeat = find(~cellfun('isempty',seppot)==1) ;
% for k=1:length(sepmeat)
%     domain = seppot{sepmeat(k)}.domain ;
%     ps_ratio{sepmeat(k)} = (new_seppot{sepmeat(k)}.T) ./ (seppot{sepmeat(k)}.T) ; % probability ratio on separators
% end


old_code_update_potentials = 0 ;
if old_code_update_potentials
% Update potentials for cliques and separatros of the orignal network
% In the process, we need to make sure the cliques (old ones 
% and new ones) match with each other.
clpot = clpot_from_engine(engine) ;
seppot = seppot_from_engine(engine) ;

for k=1:length(clpot)
    domain = clpot{k}.domain ;
    if mysubset(dummy_parents_sorted, domain)
        cid = k ;  % cid is the clique number that represent the affected clique by edit.
    end
    
    for j = 1:length(new_clpot)
        tp_pot = new_clpot{j} ;        
        new_real_domain = tp_pot.domain(find(tp_pot.sizes > 1)) ;
        if isequal(domain, new_real_domain)
            pc_ratio{k} = (new_clpot{j}.T) ./ (clpot{k}.T) ; % probability ratio on cliques
            clpot{k}.T = new_clpot{j}.T ;            
            new_clpot{j} = [] ;
            new_clpot = new_clpot(~cellfun('isempty',new_clpot)) ;
            break ;
        end
    end
end

sep1 = find(~cellfun('isempty',seppot)==1) ;
for k=1:length(sep1)
    domain = seppot{sep1(k)}.domain
    sep2 = find(~cellfun('isempty',new_seppot)==1) ;
    for j = 1:length(sep2)
        tp_pot = new_seppot{sep2(j)} ;
        new_real_domain = tp_pot.domain(find(tp_pot.sizes > 1)) ;
        if isequal(domain, new_real_domain)
            ps_ratio{sep1(k)} = (new_seppot{sep2(j)}.T) ./ (seppot{sep1(k)}.T) ; % probability ratio on separators
            seppot{sep1(k)}.T = new_seppot{sep2(j)}.T ;
            new_seppot{sep2(j)} = [] ;
            new_seppot = new_seppot(~cellfun('isempty',new_seppot)) ;
            break ;
        end
    end
end

engine = set_fields(engine, 'clpot', clpot, 'seppot', seppot); 
%engine = set_fields(engine, 'bnet', bnet) ;
end

% update asset 
% asset_full - full updating on all cliques
% asset_part - only updating the clique affected, because we only care
% about global q-value, local clique's asset table is just for the storage
% and computational saving. However, when assumed and target variables are
% not in the same clique, then more than one cliques will be affected by
% the edit. How to handle this is TBD. One extreme example is target
% variable is in one clique, and each assumed variable in one unique
% clique. 
% *******************************************************************
% Therefore, for now, the 'part' option for updating asset assume
% that all assumed variables and the target variable are in the same
% clique. So we only need to update one clique asset under this option.
% full = 1 ;
% if full
%     asset_full = asset ;
%     for k=1:length(clpot}
%         asset_full.clq{k}.T = (asset.clq{k}.T) .* pc_ratio{k} ;
%     end
%     
%     sepmeat = find(~cellfun('isempty',seppot)==1) ;
%     for k=1:length(sepmeat)
%         fillin = sepmeat(k) ;
%         asset_full.sep{fillin}.T = (asset.sep{fillin}.T) .* ps_ratio{fillin} ;        
%     end        
% else    
%     asset_part = asset ;
%     asset_part.clq{cid}.T = (asset.clq{cid(k)}.T) .* pc_ratio{cid} ;        
% end


%% full update  
%     asset_full = asset ;
%     for k=1:length(clpot)
%         asset_full.clq{k}.T = (asset.clq{k}.T) .* pc_ratio{k} ;
%     end
%     
%     sepmeat = find(~cellfun('isempty',seppot)==1) ;
%     for k=1:length(sepmeat)
%         fillin = sepmeat(k) ;
%         asset_full.sep{fillin}.T = (asset.sep{fillin}.T) .* ps_ratio{fillin} ;        
%     end        
%% part update
    asset_part = asset ;
    asset_part.clq{cid}.T = (asset.clq{cid}.T) .* pc_ratio{cid} ;        







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

dummynet.CPD(1:end-1) = bnet.CPD(:) ;
ns_dummyparent = ns(dummy_parents_sorted) ;
cc = full_combination_new(ns_dummyparent) ;
cc(:,length(dummy_parents_sorted)+1) = 1 ; % initializing

evids = cell(1, N) ;
if ~isempty(Assm)
    for k=1:length(Assm)
        evids{findindex4stringcell(node_names, Assm{k})} = assm(k) ;
    end
end
[engine, ll] = enter_evidence(engine, evids) ;
marg = marginal_nodes(engine, findindex4stringcell(node_names, Targ)) ;
% indtarg = findindex4stringcell(bnet.node_names, Targ) ;
% marg = marginal_node_from_pot(engine, indtarg, evids);
P_Targ = marg.T ;% This is P(Targ|Assm=assm)

Targ_ns = ns(findindex4stringcell(node_names, Targ)) ;
Q_Targ = zeros(1,Targ_ns) ; %This is Q(Targ|Assm=assm)
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
    if ~isempty(assm)
        if isequal(cc(k, AssmIndex), assm)  
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





