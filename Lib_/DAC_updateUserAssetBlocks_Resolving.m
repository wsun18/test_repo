
function dac = DAC_updateUserAssetBlocks_Resolving(dac, RVar, rState)
% This is to update a user's DAC including all asset blocks when resolving questions 


% dac is the struct saving a user's asset structure (Q_list, ns, base, and abc). Each 
% asset block is a struct has four fields: (1)dom; (2)var_names; (3)var_sizes; (4)T

% RVar is the list of resolving question names;
% rState is the list of resolving states corresponding to the resolving
% questions.

% resDom is the resolving question domain, which has to be a subset of
% block's domain.
% resObs is the resolved states of the resolving questions. 
% -wsun, 11/5/2013.

% global vList 

Q_list = dac.Q_list ;

if isempty(intersect(Q_list, RVar))
    return ;
end
base = dac.base ; 
ns = dac.ns;
u_abc = dac.abc ;


%%% identify the related resolving variables and their resolving states
ii = 1 ; %incremental index
for k=1:length(RVar)
    tRV = RVar{k} ;
    if ismember(tRV, Q_list)
        resDom(ii) = findindex4stringcell(Q_list, tRV) ;
        resObs(ii) = rState(k) ;        
        ii = ii + 1 ;
    end    
end


ii = 1 ; f_abc = {} ;
for j=1:length(u_abc)
    curr_dom = u_abc{j}.dom ;
    common = myintersect(curr_dom, resDom) ;
    if ~isempty(common)
        posCommon = []; 
        for k=1:length(common)
            posCommon = [posCommon find_equiv_posns(common(k), resDom)] ;
        end
        obs = resObs(posCommon) ;
        temp_ab = updateAssetBlock_Resolving(u_abc{j}, common, obs) ; 
        if ~isstruct(temp_ab)
            base =  base + temp_ab ;
        else
            f_abc{ii} = temp_ab ;
            ii = ii + 1 ;                
        end            
    else
        f_abc{ii} = u_abc{j} ;
        ii = ii + 1 ;
    end
end   

if isempty(f_abc)
    dac.Q_list = {} ;
    dac.ns = [] ;
    dac.base = base ;
    dac.abc = {} ;
    return ;
end

clear u_abc ;
u_abc = f_abc ;
clear f_abc ;

dac.base = base ;

%% update Q_list by removing resolved questions, and update block dom accordingly

Q_list(resDom) = [] ;  % remove resolved questions from Q_list
ns(resDom) = [] ;

for n=1:length(u_abc)
     local_varNames = u_abc{n}.var_names ;
     updated_dom = [] ;
     for k=1:length(local_varNames)
         updated_dom = [updated_dom findindex4stringcell(Q_list, local_varNames(k))] ;
     end
     u_abc{n}.dom = updated_dom ;
end

dac.ns = ns ;
dac.Q_list = Q_list ;
dac.abc = u_abc ;






