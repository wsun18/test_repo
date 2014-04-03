function jp = calc_joint_from_clsep(clq, sep, jstate,indstr)
% calc_joint_from_clq is to compute the global joint value based on local
% tables of cliques and separators, for a given joint state, using equation
% (product of cliques) / (product of separators) for probability, and 
% (sum of cliques) - (sum of separators) for assets.
% Assume 'jstate' contains the joint state for variables in order
% 'indstr' is a string to indicate 'prob' or 'asset'.
% -wsun, 4/23/2013

if nargin < 4, indstr='prob'; end % by default, this function is to calculate probability.

if strcmp(indstr,'prob')    
    jp = 1 ;
    for k=1:length(clq)
        domain = clq{k}.domain ;
        sz = clq{k}.sizes ;
        real_dom = domain(find(sz>1)) ;
        real_sz = sz(find(sz>1)) ;
        if ~isempty(real_dom)
            pv = jstate(real_dom) ; %position vector
            pos = find_linearIndex_from_mat(real_sz, pv) ;        
            jp = jp * clq{k}.T(pos) ;
        else
            jp = jp * clq{k}.T(1) ;
        end
    end

    sepmeat = find(~cellfun('isempty',sep)==1) ;
    for k=1:length(sepmeat)
        fillin = sepmeat(k) ;
        domain = sep{fillin}.domain ;
        sz = sep{fillin}.sizes ;
        real_dom = domain(find(sz>1)) ;
        real_sz = sz(find(sz>1)) ;
        if ~isempty(real_dom)
            pv = jstate(real_dom) ; %position vector
            pos = find_linearIndex_from_mat(real_sz, pv) ;        
            jp = jp / sep{fillin}.T(pos) ;
        else
            jp = jp / sep{fillin}.T(1) ;
        end
    end     
    return ;

elseif strcmp(indstr,'asset')
    jp = 0 ;
    for k=1:length(clq)
        domain = clq{k}.domain ;
        sz = clq{k}.sizes ;
        real_dom = domain(find(sz>1)) ;
        real_sz = sz(find(sz>1)) ;
        if ~isempty(real_dom)
            pv = jstate(real_dom) ; %position vector
            pos = find_linearIndex_from_mat(real_sz, pv) ;        
            jp = jp + clq{k}.T(pos) ;
        else
            jp = jp + clq{k}.T(1) ;
        end
    end

    sepmeat = find(~cellfun('isempty',sep)==1) ;
    for k=1:length(sepmeat)
        fillin = sepmeat(k) ;
        domain = sep{fillin}.domain ;
        sz = sep{fillin}.sizes ;
        real_dom = domain(find(sz>1)) ;
        real_sz = sz(find(sz>1)) ;
        if ~isempty(real_dom)
            pv = jstate(real_dom) ; %position vector
            pos = find_linearIndex_from_mat(real_sz, pv) ;        
            jp = jp - sep{fillin}.T(pos) ;
        else
            jp = jp - sep{fillin}.T(1) ;
        end
    end

    return ;
end    
    
error('You have to specify the correct indicator string') ;





    
    
    
    