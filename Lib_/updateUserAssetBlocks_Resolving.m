
function [u_abc, base] = updateUserAssetBlocks_Resolving(u_abc, base, RVar, rState)
% This is to update a user's all asset blocks when resolving questions 


% u_abc is the cell containing all asset blocks for a user, in which each 
% asset block is a struct has four fields: (1)dom; (2)var_names; (3)var_sizes; (4)T

% RVar is the list of resolving question names;
% rState is the list of resolving states corresponding to the resolving
% questions.

% resDom is the resolving question domain, which has to be a subset of
% block's domain.
% resObs is the resolved states of the resolving questions. 
% -wsun, 11/5/2013.

global vList 

indRVar = [] ;
for k=1:length(RVar)
    indRVar = [indRVar findindex4stringcell(vList, RVar{k})] ;
end

resDom = sort(indRVar) ;

assert(length(resDom)==length(rState)) ;

% need to adjust the right observations corresponding to the resDom.
pos = [] ; 
for i=1:length(resDom)
    pos = [pos find_equiv_posns(indRVar(i), resDom)] ;
end
resObs = rState(pos) ;



v = 1 ; f_abc = {} ;
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
            f_abc{v} = temp_ab ;
            v = v + 1 ;                
        end            
    else
        f_abc{v} = u_abc{j} ;
        v = v + 1 ;
    end
end   

if isempty(f_abc)
    clear u_abc ;
    u_abc = {} ;
    return ;
end

clear u_abc ;
u_abc = f_abc ;
clear uu_abc ;    





