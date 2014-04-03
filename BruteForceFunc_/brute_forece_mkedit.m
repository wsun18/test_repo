function [new_bf_jp bf_score bf_time] = brute_forece_mkedit(bf_jp,test_bnet,bf_score,Targ,targ,tprob,Assm,assm) ;
% This is to compute the joint probability distribution over all variables
% after making an edit, based on current 'bf_jp'
% -wsun, 4/12/2012

t0 = cputime ;

dag = test_bnet.dag ;
ns = test_bnet.node_sizes ;
N = length(ns) ;
node_names = test_bnet.node_names ;
hcc = full_combination_new(ns) ;

%CPD = test_bnet.CPD ;

if ~isempty(Assm)
    dummy_parent_names = [Assm, Targ] ;
else 
    dummy_parent_names = Targ ;
end

dummy_parents = [] ;
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

dnodes = 1:dummy ;
dummy_ns = ns ;
dummy_ns(dummy) = 2 ; % dummy node always has two states and always is observed in state one.

dummynet = mk_bnet(dag, dummy_ns, 'discrete', dnodes, 'names', node_names);


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

dummynet.CPD(1:end-1) = test_bnet.CPD(:) ; %%%% bnet.CPD have been updated from engine
ns_dummyparent = ns(dummy_parents_sorted) ;
cc = full_combination_new(ns_dummyparent) ;
cc(:,length(dummy_parents_sorted)+1) = 1 ; % initializing

% evids = cell(1, N) ;
% if ~isempty(Assm)
%     for k=1:length(Assm)
%         evids{findindex4stringcell(node_names, Assm{k})} = assm(k) ;
%     end
% end
% % [engine, ll] = enter_evidence(engine, evids) ;
% % marg = marginal_nodes(engine, findindex4stringcell(node_names, Targ)) ;
% indtarg = findindex4stringcell(bnet.node_names, Targ) ;
% marg = marginal_nodes_from_pot(engine, indtarg, evids);

% Compute current conditional probability P(Targ|Assm=assm) from joint
TargId = findindex4stringcell(node_names, Targ) ;
if ~isempty(Assm)
    for k=1:length(Assm)
        AssmId = findindex4stringcell(node_names, Assm{k}) ;
    end
end
x = reshape(bf_jp,ns) ;
P_Targ = calc_conditionalDist_from_joint(x,TargId,AssmId,assm) ;




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
dummy_sz = [ns(dummy_parents_sorted) 2] ;

dummynet.CPD{dummy} = tabular_CPD(dummynet, dummy, dummy_cpt) ;

hcc(:,dummy) = 1 ;
for k=1:size(hcc,1)
    instance = hcc(k,:) ;
    new_bf_jp(k) = compute_joint_from_CPD(dummynet.CPD, dummynet.parents, instance) ;    
end
bf_time = cputime - t0 ;
fprintf('* Brute force lock time for the trade is %10.6f cputime \n\n', bf_time) ;

new_bf_jp = new_bf_jp/sum(new_bf_jp) ; % normalization

b = 10/log(100) ;
bf_score = bf_score + b*log((new_bf_jp./bf_jp)') ;







%%%% *******************************************












