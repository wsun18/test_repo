function [new_bnet new_engine uUser] = POT_ASSET_update_BNET_AddChild_rev(engine,user,newNode,newNodeSize,parents)

%% this function is to update both potentials and users assets for the
%% extended network, assuming the added node is a child of one or more
%% existing nodes. 
%% -wsun, revised on 4/5/2013
%% -wsun, 03/05/2013


ess = 10^(-10) ;

bnet = bnet_from_engine(engine) ;
old_nodeNames = bnet.node_names ;
old_ns = bnet.node_sizes ;
old_dom = bnet.equiv_class ;

old_dag = bnet.dag ;
N = length(old_dag) ;

new_dag = old_dag ;
new_dag(N+1,:) = 0 ;
new_dag(:,N+1) = 0 ;

newNodeInd = N+1 ; % the newly added node has the last index.

new_nodeNames = old_nodeNames ;
new_nodeNames{newNodeInd} = newNode ;

parInd = [] ;
for i=1:length(parents)
    parNode = parents(i) ;
    parInd(end+1) = findindex4stringcell(old_nodeNames, parNode) ;    
end
new_dag(parInd,newNodeInd) = 1 ;

new_ns = old_ns ;
new_ns(newNodeInd) = newNodeSize ;

new_bnet = mk_bnet(new_dag, new_ns, 'discrete', 1:N+1, 'names', new_nodeNames);

% Since all computations are based on potentials, so I do not care about
% CPTs. 
for k=1:length(new_bnet.dag)
    new_bnet.CPD{k} = tabular_CPD(new_bnet,k,'CPT','unif') ;    
end

new_engine = jtree_inf_engine(new_bnet) ;
% evids = cell(1,length(new_bnet.dag)); 
% [new_engine, ll] = enter_evidence(new_engine, evids) ; 
new_clqs = cliques_from_engine(new_engine) ;
new_seps = separators_from_engine(new_engine) ;
% new_clpot = clpot_from_engine(new_engine) ;
% new_seppot = seppot_from_engine(new_engine) ;

%%% =======================================
clpot = clpot_from_engine(engine) ;
seppot = seppot_from_engine(engine) ;

for k=1:length(new_clqs)
    dom = new_clqs{k} ; % domain 
    domVars = new_bnet.node_names(dom) ; % domain variable names
    clq_Ind = clq_containing_nodes_usingNames(engine, domVars) ;
    if clq_Ind > 0
        % two domains have to be exactly same
        assert(length(domVars)==length(clpot{clq_Ind}.domain)) ;
        assert(isempty(find(strcmp(domVars,old_nodeNames(clpot{clq_Ind}.domain))==0)))
        %assert(isempty(setdiff(domVars,old_nodeNames(clpot{clq_Ind}.domain)))) ;
        %assert(isempty(setdiff(old_nodeNames(clpot{clq_Ind}.domain),domVars))) ;
        new_clpot(k) = clpot(clq_Ind) ;
        new_clpot{k}.domain = dom ;
    end
    if clq_Ind < 0
        for h=1:length(domVars)
            clqIndSet(h) = clq_containing_nodes_usingNames(engine,domVars(h)) ;
        end
        clqIndSet = unique(clqIndSet) ;
        
        new_clpot{k} = POT_to_new_domain(clpot,clqIndSet,dom) ;        
        assert(abs(sum(new_clpot{k}.T(:)) - 1) < ess ) ;
    end
    if isempty(clq_Ind) % for the clique containing the new domain variable
        existingVars = intersect(domVars,old_nodeNames) ;
        for h=1:length(existingVars)
            clqIndSet(h) = clq_containing_nodes_usingNames(engine,existingVars(h)) ;
        end
        clqIndSet = unique(clqIndSet) ;
        
        new_clpot{k} = POT_to_new_domain(clpot,clqIndSet,dom,newNodeInd,newNodeSize) ;
        assert(abs(sum(new_clpot{k}.T(:)) - 1) < ess ) ;        
    end
end

% update separator potentials. 
sepmeat = find(~cellfun('isempty',new_seps)==1) ;
for k=1:length(sepmeat)
    fillin = sepmeat(k) ;
    sep_dom = new_seps{fillin} ;
    
    clqId = clq_containing_nodes(new_engine,sep_dom) ;
    new_seps{fillin} = Pot_project_to_subdomain(new_clpot{clqId},sep_dom);
    assert(abs(sum(new_seps{fillin}.T(:)) - 1) < ess ) ;
end    

new_engine = set_fields(new_engine,'clpot',new_clpot) ;
new_engine = set_fields(new_engine,'seppot',new_seps) ;

%%% *****************************************
%%% Asset update for active users 
activeUser = find(~isemptycell(user)) ;
new_aPot = new_clqs ;
new_aSep = new_seps ;
old_sepAsset = user{activeUser(1)}.asset.sep ;
old_sepmeat = find(~isemptycell(old_sepAsset)) ;
initAssetValue = old_sepAsset{old_sepmeat(1)}.T(1) ;
for u=1:length(activeUser)
    uInd = activeUser(u) ;
    uAsset = user{uInd}.asset ;
    aPot = uAsset.clq ;
    for k=1:length(new_clqs)        
        dom = new_clqs{k} ; % domain 
        domVars = new_bnet.node_names(dom) ; % domain variable names
        clq_Ind = clq_containing_nodes_usingNames(engine, domVars) ;
        if clq_Ind > 0
            % two domains have to be exactly same
            assert(length(domVars)==length(clpot{clq_Ind}.domain)) ;
            assert(isempty(find(strcmp(domVars,old_nodeNames(clpot{clq_Ind}.domain))==0)))
            %assert(isempty(setdiff(domVars,old_nodeNames(clpot{clq_Ind}.domain)))) ;
            %assert(isempty(setdiff(old_nodeNames(clpot{clq_Ind}.domain),domVars))) ;
            new_aPot(k) = aPot(clq_Ind) ;
            %new_aPot{k}.domain = dom ;
        end
        if clq_Ind < 0
            for h=1:length(domVars)
                clqIndSet(h) = clq_containing_nodes_usingNames(engine,domVars(h)) ;
            end
            clqIndSet = unique(clqIndSet) ;            
            new_aPot{k} = ASSET_to_new_domain(uAsset,clqIndSet,dom) ;
        end
        if isempty(clq_Ind) % for the clique containing the new domain variable            
            existingDom = myintersect(dom,old_dom) ;
            existingNodeSizes = old_ns(existingDom) ;
            dom_ns = [existingNodeSizes newNodeSize] ;
            dom_T = initAssetValue * ones(dom_ns) ;
            new_aPot{k} = dpot(dom, dom_ns, dom_T);
        end
    end
    
    % since we never update separators, so we just need to re-initialize
    % new separators with the starting scores    
    for j=1:length(sepmeat)
        fillin = sepmeat(j) ;
        sep_dom = new_seps{fillin} ;
        new_aSep{j}.domain = sep_dom ;
        new_aSep{j}.domain = sep_dom ;
        new_aSep{j}.domain = sep_dom ;
    end
    
    user{uInd}.asset.clq = new_aPot ;
    user{uInd}.asset.sep = new_aSep ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function new_apot = ASSET_to_new_domain(asset,clqIndSet,newDom,newNodeInd,newNodeSize)

if nargin < 4
    newNodeInd = [] ; newNodeSize = [] ;
end

assert(length(clqIndSet)==2) ;
clqInd1 = clqIndSet(1) ;
clqInd2 = clqIndSet(2) ;

clpot = asset.clq ;
seppot = asset.sep ;
sepmeat = find(~cellfun('isempty',seppot)==1) ;

pot1 = clpot{clqInd1} ;
pot2 = clpot{clqInd2} ;

dom1 = pot1.domain ;
dom2 = pot2.domain ;

common = myintersect(dom1,dom2) ;
for k=1:length(sepmeat)
    fillin = sepmeat(k) ;
    sep_dom = seppot{fillin}.domain ;    
    if isequal(common,sep_dom)
        pot_common = seppot{fillin} ;
        break ;
    end    
end 
%pot_common = ASSET_project_to_subdomain(pot1,common) ;
joint_dom = union(dom1,dom2) ;

% to figure out node_sizes for joint domain
for i=1:length(joint_dom)
    d = joint_dom(i) ;
    if (mysubset(d,pot1.domain))         
        joint_ns(i) = pot1.sizes(find(pot1.domain==d)) ;  
    else
        assert(mysubset(d,pot2.domain)) ;
        joint_ns(i) = pot2.sizes(find(pot2.domain==d)) ;
    end
end

%% To find the indices in the joint domain for variable in different domains
% for j=1:length(dom1)
%     var = dom1(j) ;
%     dom1_index(j) = find(joint_dom==var) ;
% end
%  
% for j=1:length(dom2)
%     var = dom2(j) ;
%     dom2_index(j) = find(joint_dom==var) ;
% end
% 
% for j=1:length(common)
%     var = common(j) ;
%     common_index(j) = find(joint_dom==var) ;
% end

% Example to check right index
%      2 4 8 9
% dom1 8 2 4
% ind1 3 1 2
% dom2 4 9 8
% ind2 2 4 3



%% compute the probabilities of joint space over two cliques
dom1_index = find_equiv_posns(dom1, joint_dom) ;
dom2_index = find_equiv_posns(dom2, joint_dom) ;
common_index = find_equiv_posns(common, joint_dom) ;
j_cc = full_combination_new(joint_ns) ;
for k=1:size(j_cc,1)
    instance = j_cc(k,:) ; 
    dom1_inst = instance(dom1_index) ;
    dom2_inst = instance(dom2_index) ;
    common_inst = instance(common_index) ;
    pb1 = pot1.T(find_linearIndex_from_mat(pot1.sizes,dom1_inst)) ;
    pb2 = pot2.T(find_linearIndex_from_mat(pot2.sizes,dom2_inst)) ;
    pb3 = pot_common.T(find_linearIndex_from_mat(pot_common.sizes,common_inst)) ;
    new_jp(k) = pb1 + pb2 - pb3 ;    
end


% jointPot.domain = joint_dom ;
% jointPot.T = reshape(new_jp,joint_ns)
% jointPot.sizes = joint_ns ;
joint_aPot = dpot(joint_dom, joint_ns, reshape(new_jp,joint_ns));

if ~isempty(newNodeInd) %
    existingNodesDom = mysetdiff(newDom,newNodeInd) ;
    tempPot = ASSET_project_to_subdomain_rev(joint_aPot,existingNodesDom) ;
    % assuming the new adding node has uniform CPT
    TT = tempPot.T ;
    nodeSize = joint_ns(end) ;
    final_dom = tempPot.domain ;
    final_dom(end+1) = newNodeInd ;
    final_ns = tempPot.sizes ;
    final_ns(end+1) = newNodeSize ;
    new_jp = reshape(repmat(TT,[1,newNodeSize]), final_ns) ;
        
    new_apot = dpot(final_dom, final_ns, new_jp) ; 
    
    return ;
end

new_apot = ASSET_project_to_subdomain_rev(joint_aPot,newDom) ;














%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % assuming the added node are always child of existing nodes, so we do not
% % have to worry complicated CPT. Code modification needed for general case
% % later on
% % % for k=1:length(new_bnet.node_names)
% % %     currNode = new_bnet.node_names(k);
% % %     currNodeInd_new = findindex4stringcell(new_bnet.node_names, currNode) ;
% % %     currNodeInd_old = findindex4stringcell(old_nodeNames, currNode) ;
% % %     if currNodeInd_old > 0
% % %         new_bnet.CPD{currNodeInd_new} = bnet.CPD{currNodeInd_old} ;
% % %     else
% % %         new_bnet.CPD{currNodeInd_new} = tabular_CPD(new_bnet,...
% % %             currNodeInd_new,'CPT','unif') ;
% % %     end
% % % end

