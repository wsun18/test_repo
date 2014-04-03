function [new_bnet new_engine] = mk_addnode_bnet(engine,node,size,parents,children)

%% this function is to build an extended BN by adding a 'node' to the current
%% 'bnet', its parents/children have to be in the current 'bnet'.
%% -wsun, 02/07/2013

bnet = bnet_from_engine(engine) ;
old_nodeNames = bnet.node_names ;

dag = bnet.dag ;
N = length(dag) ;
dag(N+1,:) = 0 ;
dag(:,N+1) = 0 ;

if ~isempty(children)
    chdInd = [] ;
    for i=1:length(children)
        chdNode = children(i) ;
        chdInd(end+1) = findindex4stringcell(bnet.node_names, chdNode) ;    
    end
    nodeInd = min(chdInd) ;
    chdInd = chdInd + 1 ;
    dag(nodeInd,chdInd) = 1 ;
    bnet.node_names(nodeInd+1:N+1) = bnet.node_names(nodeInd:end) ;    
else
    nodeInd = N+1 ;    
end
bnet.node_names{nodeInd} = node ;

if ~isempty(parents)
    parInd = [] ;
    for i=1:length(parents)
        parNode = parents(i) ;
        parInd(end+1) = findindex4stringcell(bnet.node_names, parNode) ;    
    end
    for j=1:length(parInd)
        pInd = parInd(j) ;
        if pInd > nodeInd  % if the parents node has higher index
            movPar = bnet.node_names(pInd) ;
            bnet.node_names(nodeInd+1:end+1) = bnet.node_names(nodeInd:end) ;
            bnet.node_names(nodeInd) = movPar ;
            bnet.node_names(pInd+1) = [] ;  % delete the node after moving
            pInd = nodeInd ;
            nodeInd = nodeInd + 1 ;            
        end
        dag(pInd,nodeInd) = 1 ;
    end
end

old_node_Ind = [];
for k=1:length(old_nodeNames)
    oldnode = old_nodeNames(k) ;
    old_node_Ind(end+1) = findindex4stringcell(bnet.node_names, oldnode) ;    
end

ns = zeros(1,N+1) ;
ns(old_node_Ind) = bnet.node_sizes ;
ns(nodeInd) = size ;

new_bnet = mk_bnet(dag, ns, 'discrete', 1:N+1, 'names', bnet.node_names);

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
        assert(sum(new_clpot{k}.T(:))==1) ;
    end
    if isempty(clq_Ind) % for the clique containing the new domain variable
        existingVars = intersect(domVars,old_nodeNames) ;
        for h=1:length(existingVars)
            clqIndSet(h) = clq_containing_nodes_usingNames(engine,existingVars(h)) ;
        end
        clqIndSet = unique(clqIndSet) ;
        
        new_clpot{k} = POT_to_new_domain(clpot,clqIndSet,dom,nodeInd,size) ;
        assert(sum(new_clpot{k}.T(:))==1) ;        
    end
end

% update separator potentials. 
sepmeat = find(~cellfun('isempty',new_seps)==1) ;
for k=1:length(sepmeat)
    fillin = sepmeat(k) ;
    sep_dom = new_seps{fillin} ;
    
    clqId = clq_containing_nodes(new_engine,sep_dom) ;
    new_seps{fillin} = Pot_project_to_subdomain(new_clpot{clqId},sep_dom);
    assert(sum(new_seps{fillin}.T(:))==1) ;
end    

new_engine = set_fields(new_engine,'clpot',new_clpot) ;
new_engine = set_fields(new_engine,'seppot',new_seps) ;


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

