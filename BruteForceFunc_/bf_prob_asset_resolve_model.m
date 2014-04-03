function [model jp user] = bf_prob_asset_resolve_model(user,jp_base,base_model,RVar,rState) 
% This is to update all users' asset and the joint probability when
% resolving a set of questions in the base model. It also returns 
% the new updated model as well.
% 9/19/12, wsun

activeUser = find(~isemptycell(user)) ;

baseVar = base_model.node_names ;
baseNS = base_model.sizes ;

indResolve = [] ;
for k=1:length(RVar)
    indResolve = [indResolve findindex4stringcell(baseVar, RVar{k})] ;
end

stayVar = setdiff(baseVar,RVar) ;
indStay = [] ;
for k=1:length(stayVar)
    indStay = [indStay findindex4stringcell(baseVar, stayVar{k})] ;
end

if isempty(indStay)
    model.node_names = {} ;
    model.sizes = [] ;
    for k=1:length(activeUser)
        uInd = activeUser(k) ;        
        user{uInd}.asset = user{uInd}.asset(rState) ;                
        user{uInd}.cash = user{uInd}.asset ;
        user{uInd}.scoreEV = user{uInd}.cash  ;
    end 
    jp = 1 ;
    return ;
end

model.node_names = stayVar ;
model.sizes = baseNS(indStay) ;
model.domain = indStay ;
ns = model.sizes ;


h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances

%%%%%%%% calculating new joint probability
for i=1:noi
    instance = h_cc(i,:); 
    baseIns(indStay) = instance ;
    baseIns(indResolve) = rState ;    
    posBase = find_linearIndex_from_mat(baseNS,baseIns);
    
    jp(i) = jp_base(posBase) ;
    
    %%%%%%%%%%% extract users' asset from the corresponding state    
    for k=1:length(activeUser)
        uInd = activeUser(k) ;
        user{uInd}.temp_asset(i) = user{uInd}.asset(posBase) ;
    end
end

jp = reshape(jp,[noi 1]) ;
jp = jp/sum(jp) ;

for k=1:length(activeUser)
    uInd = activeUser(k) ;
    user{uInd}.temp_asset = reshape(user{uInd}.temp_asset,[noi 1]) ;
    user{uInd}.asset = user{uInd}.temp_asset ;        
    user{uInd} = rmfield(user{uInd},'temp_asset') ;
    user{uInd}.cash = bf_min_asset(model, user{uInd}.asset) ;
    user{uInd}.scoreEV = bf_scoreEV(model,jp,user{uInd}.asset)  ;
end    




