function [clpot seppot] = mk_edit_exclude_targ(engine, Targ, targ, Assm, assm) 
% This function mk_edit is to update the probabilities and assets by
% cliques and separators for the original network given an edit

if nargin == 0, error('It has to have arguments'); end
if nargin <= 3, Assm = {}; assm=[]; end

tprob = 0 ; % make it equivalently excluding the state Targ=targ.

[dummynet dummy_parents_sorted] = mk_dummynet(engine, Targ, targ, tprob, Assm, assm) ;
dummy = length(dummynet.dag) ;
% print out CPT of dummy node
dummy_cpd = dummynet.CPD{dummy} ; 
dummy_cpt = CPD_to_CPT(dummy_cpd) ;

% propagate and update probabilities for this new network with the dummy node
engine_temp = jtree_inf_engine(dummynet) ;
evids = cell(1, dummy) ;
evids{dummy} = 1 ; % dummy node is always observed at the first state.
if ~isempty(Assm)
    bnet = bnet_from_engine(engine) ;
    for k=1:length(assm)
        indassm(k) = findindex4stringcell(bnet.node_names, Assm{k}) ;
        evids{indassm(k)} = assm(k) ;
    end
end
engine_temp = enter_evidence(engine_temp, evids) ; 

new_clpot = clpot_from_engine(engine_temp) ;
new_seppot = seppot_from_engine(engine_temp) ;

update_potentials = 1 ;
if update_potentials
% Update potentials for cliques and separatros of the orignal network
% In the process, we need to make sure the cliques (old ones 
% and new ones) match with each other.
clpot = clpot_from_engine(engine) ;
seppot = seppot_from_engine(engine) ;

for k=1:length(clpot)
    domain = clpot{k}.domain ;    
    
    for j = 1:length(new_clpot)
        tp_pot = new_clpot{j} ;        
        new_real_domain = mysetdiff(tp_pot.domain,dummy) ;
        if isequal(domain, new_real_domain)
            clpot{k}.T = new_clpot{j}.T ;            
            clpot{k}.sizes = new_clpot{j}.sizes(1:length(new_real_domain)) ; 
            new_clpot{j} = [] ;
            new_clpot = new_clpot(~cellfun('isempty',new_clpot)) ;
            break ;
        end
    end
end

sep1 = find(~cellfun('isempty',seppot)==1) ;
for k=1:length(sep1)
    domain = seppot{sep1(k)}.domain ;
    sep2 = find(~cellfun('isempty',new_seppot)==1) ;
    for j = 1:length(sep2)
        tp_pot = new_seppot{sep2(j)} ;
        new_real_domain = mysetdiff(tp_pot.domain,dummy) ;
        if isequal(domain, new_real_domain)
            %ps_ratio{sep1(k)} = (new_seppot{sep2(j)}.T) ./ (seppot{sep1(k)}.T) ; % probability ratio on separators
            seppot{sep1(k)}.T = new_seppot{sep2(j)}.T ;
            seppot{sep1(k)}.sizes = new_seppot{sep2(j)}.sizes(1:length(new_real_domain)) ;
            new_seppot{sep2(j)} = [] ;
            new_seppot = new_seppot(~cellfun('isempty',new_seppot)) ;
            break ;
        end
    end
end

%engine = set_fields(engine, 'clpot', clpot, 'seppot', seppot); 
%engine = set_fields(engine, 'bnet', bnet) ;
end %%%% end of update_potentials


    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ********************************************************************

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





