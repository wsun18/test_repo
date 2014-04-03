
function DAC_cash = DAC_VP_find_cash(dac, resDom, resObs)
% This is to find cash by user's DAC, including asset blocks containing
% VP-node. 
% DAC stands for Dynamic Asset Cluster model

% input: if there is any observations, resDom represents the resolving
% domains, resObs represents the resolving states. 

% Because the given questions may include VP questions, and if so,
% VP-node's given state may be an interval. 

% -wsun, 3/31/2014.

if nargin < 3, resDom = {}; resObs = []; end 

%disp('hello, DAC find cash') ;

base = dac.base ;
u_abc = dac.abc ;

if ~isempty(resDom)
    v = 1 ;
    for j=1:length(u_abc)
        curr_dom = u_abc{j}.dom ;
        common = myintersect(curr_dom, resDom) ;
        if ~isempty(common)
            posCommon = find_equiv_posns(common, resDom) ;
            obs = resObs(posCommon) ;
            temp_ab = updateAssetBlock_Resolving(u_abc{j}, common, obs) ; 
            if ~isstruct(temp_ab)
                base =  base + temp_ab ;
            else
                uu_ab{v} = temp_ab ;
                v = v + 1 ;                
            end            
        else
            uu_ab{v} = u_abc{j} ;
            v = v + 1 ;
        end
    end   
    
    clear u_ab ;
    u_abc = uu_ab ;
    clear uu_ab ;    
end

if isempty(u_abc)
    DAC_cash = base ;
    return ;
end

if length(u_abc)==1 % only one asset block in user asset structure.
    DAC_cash = base + min(u_abc{1}.T(:)) ;
    return ;
end


% load undirected graph from asset blocks
for i=1:length(u_abc)
    curr_dom = u_abc{i}.dom ;
    curr_sizes = u_abc{i}.var_sizes ;
    MG(curr_dom, curr_dom) = 1 ; 
    ns(curr_dom) = curr_sizes ;
end
MG = setdiag(MG,0) ;


[~, ~, cliques] = graph_to_jtree(MG, ns) ;


%%%%%%%% adjust cliques, because a number of NULL cliques may be generated by MG
v = 1 ;
for i=1:length(cliques)
    tempdom = cliques{i} ;
    
    if isempty(find(ns(tempdom), 1)) 
        disp('NULL clique') ;
    elseif length(find(ns(tempdom)>0)) < length(tempdom)
        disp('some variables in one clique have size 0') ;
    else
        v_clq{v} = cliques{i} ;
        v = v + 1 ;        
    end        
end
clear cliques ;
cliques = v_clq ;
clear v_clq ;

% regenerated the jtree based on adjusted cliques.
[jtree, root] = cliques_to_jtree(cliques, ns) ;


[jtree, postorder] = my_mk_rooted_tree(jtree, root) ;

% collect 
postorder_parents = cell(1,length(postorder));
for n=postorder(:)'
  postorder_parents{n} = parents(jtree, n);
end


% Constructing asset table for new cliques. 
% For each clique, we have to check all existing asset blocks, and see if
% the block's domain is the subset of the clique. If so, we need to
% integrate its asset table by extending it into clique space. And summing
% up all blocks satisfying the subset condition. 
% 
% Asset block is a compact representation for user's trading history.

for j=1:length(cliques)
    dom = cliques{j} ;
    clpot{j}.dom = dom ;
    clq_sz = ns(dom) ;
    if length(dom) == 1 ;
        clq_T = zeros(clq_sz,1) ;
    else
        clq_T = zeros(clq_sz) ;        
    end   
    
    clpot{j}.sizes = clq_sz ;    
    
    for k=1:length(u_abc)
        b_dom = u_abc{k}.dom ;
        
        if mysubset(b_dom, dom)
            % extend the block to the clique, then summing up
            smallT = u_abc{k}.T ;
            smalldom = b_dom ;
            smallsz = u_abc{k}.var_sizes ;
            bigdom = dom ;
            bigsz = clq_sz ;
            Ts = extend_domain_table(smallT, smalldom, smallsz, bigdom, bigsz);
            clq_T = clq_T + Ts ;
        end        
    end    
    clpot{j}.T = clq_T ;    
end



DAC_worst = ONEWAY_DAC_propagation(jtree, clpot, postorder, postorder_parents) ;

DAC_cash = base + DAC_worst ;


%%%%%%%%%%%%%%%%
function worst = ONEWAY_DAC_propagation(jtree, clpot, postorder, postorder_parents)
% One way propagation to find the minimum number by jtree min-propagation
% -wsun, 11/2/2013.


moption = 'min' ;
for n=postorder %postorder(1:end-1)
  for p=postorder_parents{n}
    %qclq{p} = divide_by_pot(qclq{p}, qsep{p,n}); % qsep is not 1, so need to run the computation
    %seppot{p,n} = marginalize_pot(clpot{n}, engine.separator{p,n}, engine.maximize);
    %modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
    %-wsun
    onto = myintersect(clpot{n}.dom, clpot{p}.dom) ;
    if isempty(onto)
        temp_T = clpot{p}.T(:) + min(clpot{n}.T(:)) ;
        if length(clpot{p}.dom) == 1
            clpot{p}.T = reshape(temp_T, [clpot{p}.sizes 1]) ;
        else
            clpot{p}.T = reshape(temp_T, clpot{p}.sizes) ;
        end
    else
        bigdom = clpot{n}.dom;
        bigT = clpot{n}.T ;
        bigsz = clpot{n}.sizes;
        
        smallT = marg_table(bigT, bigdom, bigsz, onto, moption) ;        
        posOnto = [] ;
        for xi=1:length(onto)
            posOnto = [posOnto find_equiv_posns(onto(xi), bigdom)] ;
        end
        smallsz = bigsz(posOnto) ;
        
        % now we are passing information to the target clique which is
        % clpot{p}. - wsun, 11/5/2013.
        bigdom = clpot{p}.dom ;
        bigsz = clpot{p}.sizes ;        
        Ts = extend_domain_table(smallT, onto, smallsz, bigdom, bigsz);
        assert(length(Ts(:))==length(clpot{p}.T(:))) ;
        temp_T = clpot{p}.T(:) + Ts(:) ;
        if length(clpot{p}.dom) == 1
            clpot{p}.T = reshape(temp_T, [clpot{p}.sizes 1]) ;
        else
            clpot{p}.T = reshape(temp_T, clpot{p}.sizes) ;
        end        
    end
  end
end

worst = min(clpot{n}.T(:)) ;


%%%%%%%%%%%%%%%%%%%%%%
function [T, post, cycle] = my_mk_rooted_tree(G, root)
% MK_ROOTED_TREE Make a directed tree pointing away from root
% [T, pre, post, cycle] = mk_rooted_tree(G, root)

n = length(G);
T = sparse(n,n); % not the same as T = sparse(n) !
directed = 0;
[d, pre, post, cycle, f, pred] = dfs(G, root, directed);
[junk, pre2] = sort(d);
assert(isequal(pre, pre2))
[junk, post2] = sort(f);
assert(isequal(post, post2));
%[d, pre, post, cycle, f, pred] = dfs(G, [], directed);
for i=1:length(pred)
  if pred(i)>0
    T(pred(i),i)=1;
  end
end

