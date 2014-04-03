function root = findroot_original(bnet, cliques, jtree)

%% findroot is to find the strong root in a clique tree assume it has one
%% in the tree. Strong triangulated tree is guaranteed to have a strong 
%% root clique. 

%% wsun, 12/7/09



% the logic is wrong in the following code, because I mistakenly think that
% any summing out of discrete variable for hybrid clique is forbidden in 
% upstream passing. But actually, it is allowable if the separator is 
% pure discrete. - figured out on 4/20/10, wsun.
% for k=1:length(is)
%     i = is(k); j = js(k) ;
%     % variables in common
%     common = intersect(cliques{i}, cliques{j}) ;
%     % variables only in the first set, not in the second set.
%     self_only = setdiff(cliques{i}, cliques{j}) ; 
%     % check hybrid clique
%     if ~isempty(intersect(cliques{i},bnet.cnodes)) & ~isempty(intersect(cliques{i},bnet.dnodes))
%         if mysubset(self_only,bnet.cnodes)
%             rtree(i,j) = 1 ;
%         end
%     else
%         rtree(i,j) = 1 ;
%     end
% end
        
if 1
% logic 2 - choose the hybrid clique that containing the max number 
% of interface nodes to be the strong root.
n0 = 0 ;
for i=1:length(cliques)
    % check hybrid cliques
    hc = intersect(cliques{i}, bnet.cnodes) ; 
    hd = intersect(cliques{i}, bnet.dnodes) ;
    if ~isempty(hd) & ~isempty(hc)
        nd = length(hd) ;
        if nd > n0
            root = i ;
            n0 = nd ;
        end
    end    
end

end
%%%%%%%%%%%%%%%%%%%%%%%


if 0
% logic 1 - thoroughly searching cliques and choose the one to make any
% other pairs of cliques satisfying the traditional two conditions.

[is js] = find(jtree > 0) ;

num_clqs = length(cliques) ;
rtree = zeros(num_clqs) ;
     
for k=1:length(is)
    i = is(k); j = js(k) ;
    common = intersect(cliques{i}, cliques{j}) ;
    self_only = setdiff(cliques{i}, cliques{j}) ; % variables only in the first set, not in the second set.
    if mysubset(self_only, bnet.cnodes) | mysubset(common, bnet.dnodes)
        rtree(i,j) = 1;
    end        
end

root = find(sum(rtree,2)==0) ;

end





