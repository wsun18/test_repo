function [model jp user] = bf_prob_asset_add_model(user,jp_base,base_model,add_model) 
% This is to update all users' asset and the joint probability when adding
% new questions to the current base model. It also returns the new updated
% model as well.
% 9/19/12, wsun

global b log_base ; %defined only once, usually defined in main function

baseVar = base_model.node_names ;
addVar = add_model.node_names ;

baseNS = base_model.sizes ;
addNS = add_model.sizes ;

%%%% assuming uniform joint probability for the adding model
jp_add = 1/(prod(addNS)) * ones(prod(addNS),1) ;

model.node_names = [baseVar addVar] ;
model.sizes = [baseNS addNS] ;

node_names = model.node_names ;
ns = model.sizes ;

indBase = [] ;
for k=1:length(baseVar)
    indBase = [indBase findindex4stringcell(node_names, baseVar{k})] ;
end

indAdd = [] ;
for k=1:length(addVar)
    indAdd = [indAdd findindex4stringcell(node_names, addVar{k})] ;
end

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances

%%%%%%%% calculating new joint probability
for i=1:noi
    %i
    instance = h_cc(i,:); 
    if ~isempty(indBase)
        baseIns = instance(indBase) ;
    else
        baseIns = 1 ;
        baseNS = 1 ;
    end
    addIns = instance(indAdd) ;
    posBase = find_linearIndex_from_mat(baseNS,baseIns);
    posAdd = find_linearIndex_from_mat(addNS,addIns);
    
    jp(i) = jp_base(posBase) * jp_add(posAdd) ;
    
    %%%%%%%%%%% adjusting users' asset for the new extended model    
    for k=1:length(user)
        if ~isempty(user{k})
            user{k}.asset(i,1) = user{k}.asset(posBase) ;
        end
    end    
end

jp = reshape(jp,[noi 1]) ;
%sum(jp)

for k=1:length(user)
    if ~isempty(user{k})
        user{k}.scoreEV = bf_scoreEV(model,jp,user{k}.asset) ;
    end
end 

