function new_pot = POT_to_new_domain(clpot,clqIndSet,newDom,newNodeInd,newNodeSize)
%% 
%% -wsun, 02/08/2013

% Assuming only two cliques are being combined; 
% Joint probabilities over the new joint space are calculated using the
% formula - 'P(C_i) * P(C_j)/P(intersectionOfC_iAndC_j)', so we need to
% compute the probabilities over the common domain first.

if nargin < 4
    newNodeInd = [] ; newNodeSize = [] ;
end


assert(length(clqIndSet)==2) ;
clqInd1 = clqIndSet(1) ;
clqInd2 = clqIndSet(2) ;

pot1 = clpot{clqInd1} ;
pot2 = clpot{clqInd2} ;

dom1 = pot1.domain ;
dom2 = pot2.domain ;

common = myintersect(dom1,dom2) ;
pot_common = Pot_project_to_subdomain(pot1,common) ;
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

% to find the indices in the joint domain for variable in different domains
for j=1:length(dom1)
    var = dom1(j) ;
    dom1_index(j) = find(joint_dom==var) ;
end
 
for j=1:length(dom2)
    var = dom2(j) ;
    dom2_index(j) = find(joint_dom==var) ;
end

for j=1:length(common)
    var = common(j) ;
    common_index(j) = find(joint_dom==var) ;
end

% Example to check right index
%      2 4 8 9
% dom1 8 2 4
% ind1 3 1 2
% dom2 4 9 8
% ind2 2 4 3



%% compute the probabilities of joint space over two cliques
j_cc = full_combination_new(joint_ns) ;
for k=1:size(j_cc,1)
    instance = j_cc(k,:) ; 
    dom1_inst = instance(dom1_index) ;
    dom2_inst = instance(dom2_index) ;
    common_inst = instance(common_index) ;
    pb1 = pot1.T(find_linearIndex_from_mat(pot1.sizes,dom1_inst)) ;
    pb2 = pot2.T(find_linearIndex_from_mat(pot2.sizes,dom2_inst)) ;
    pb3 = pot_common.T(find_linearIndex_from_mat(pot_common.sizes,common_inst)) ;
    new_jp(k) = pb1 * pb2 / pb3 ;    
end


% jointPot.domain = joint_dom ;
% jointPot.T = reshape(new_jp,joint_ns)
% jointPot.sizes = joint_ns ;
jointPot = dpot(joint_dom, joint_ns, reshape(new_jp,joint_ns));

if ~isempty(newNodeInd)
    existingNodesDom = mysetdiff(newDom,newNodeInd) ;
    tempPot = Pot_project_to_subdomain(jointPot,existingNodesDom) ;
    % assuming the new adding node has uniform CPT
    TT = tempPot.T ;
    nodeSize = joint_ns(end) ;
    final_dom = tempPot.domain ;
    final_dom(end+1) = newNodeInd ;
    final_ns = tempPot.sizes ;
    final_ns(end+1) = newNodeSize ;
    new_jp = reshape(repmat(TT,[1,newNodeSize]), final_ns) * .5 ;
        
    new_pot = dpot(final_dom, final_ns, new_jp) ; 
    
    return ;
end

new_pot = Pot_project_to_subdomain(jointPot,newDom) ;



