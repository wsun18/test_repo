function [jp jslist] = bruteforce_joint_from_clsep(engine, evidence)
% bruteforce_joint_from_clq is to compute the global joint value based on local
% tables of cliques and separators, for all joint states, using equation
% (product of cliques) / (product of separators)
% Assume 'jstate' contains the joint state for variables in order

clq = clpot_from_engine(engine) ;
sep = seppot_from_engine(engine) ;
bnet = bnet_from_engine(engine) ;

observed = find(~isemptycell(evidence)) ;
hidden = find(isemptycell(evidence)) ;
hsizes = bnet.node_sizes(hidden) ;
h_cc = full_combination_new(hsizes) ;

jslist(:,hidden) = h_cc ;
if ~isempty(observed)
    tpo = repmat(cell2num(evidence(observed)), size(h_cc,1),1) ;
    jslist(:,observed) = tpo ;
end

% for i=1:size(h_cc,1)
%     jslist(i,hidden) = h_cc(i,:) ;
%     jslist(i,observed) = cell2num(evidence(observed)) ;
% end
    

for k=1:size(jslist,1) 
    jp(k) = calc_joint_from_clsep_v1(clq,sep,jslist(k,:), observed) ;
end



function jp = calc_joint_from_clsep_v1(clq, sep, jstate, observed) 


jp = 1 ;
for k=1:length(clq)
    domain = clq{k}.domain ;
    sz = clq{k}.sizes ;
    if myintersect(domain,observed)
        jstate(observed) = 1 ;
    end
    pv = jstate(domain) ; %position vector    
    pos = find_linearIndex_from_mat(sz, pv) ;        
    jp = jp * clq{k}.T(pos) ;
end

sepmeat = find(~cellfun('isempty',sep)==1) ;
for k=1:length(sepmeat)
    fillin = sepmeat(k) ;
    domain = sep{fillin}.domain ;
    sz = sep{fillin}.sizes ;
    if myintersect(domain,observed)
        jstate(observed) = 1 ;
    end
    pv = jstate(domain) ;
    pos = find_linearIndex_from_mat(sz, pv) ;
    jp = jp / sep{fillin}.T(pos) ;
end  

    
    
    
    