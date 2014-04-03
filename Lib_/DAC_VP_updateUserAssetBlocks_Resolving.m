
function dac = DAC_VP_updateUserAssetBlocks_Resolving(dac, RVar, rState)
% This is to update a user's DAC including all asset blocks when resolving
% a set of questions which may include VP questions.


% dac is the struct saving a user's asset structure (Q_list, ns, base, and abc). Each 
% asset block is a struct has four fields: (1)dom; (2)var_names; (3)var_sizes; (4)T

% RVar: is the list of resolving questions, may include VP questions;
% rState: is the list of resolving states corresponding to the resolving
% questions. 
% *** RVar is a cell may contain struct element, and string. 

% -wsun, 3/31/2014

Obj_list = dac.Obj_list ;
Q_list = dac.Q_list ;

N = length(RVar) ;
resNames = cell(1,N) ;
for i=1:N
    tp = RVar{i} ;
    if isstruct(tp)
        resNames{i} = tp.strname ;
    elseif ischar(tp)
        resNames{i} = tp ;
    end
end

if isempty(intersect(Q_list, resNames))
    return ;
end

base = dac.base ; 
ns = dac.ns;
u_abc = dac.abc ;


%%% identify the related resolving variables and their resolving states
% resDom is the resolving question domain, which has to be a subset of
% block's domain.
% resObs is the resolved states of the resolving questions. 
% -wsun, 11/5/2013.
ii = 1 ; %incremental index
for k=1:N
    tpObj = RVar{k} ;
    tp_value = rState(k) ;
    if isstruct(tpObj)
        tRV = tpObj.strname ;
        resIntState = DAC_VP_atomic2intervalstate(tpObj, tp_value) ;
        flag = 1 ;
    elseif ischar(tpObj)
        tRV = tpObj ;
        flag = 0 ;
    end
    
    if ismember(tRV, Q_list)
        resDom(ii) = findindex4stringcell(Q_list, tRV) ;
        if flag
            resObs(ii) = resIntState ;
        else
            resObs(ii) = tp_value ;
        end
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






