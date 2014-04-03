function asset = bf_asset_resolve_model(asset,model,RVar,rState) 
% This is to update the user' asset when
% resolving a set of questions in the model. 
% 10/10/12, wsun
    
    
baseVar = model.node_names ;
baseNS = model.sizes ;

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
    asset = asset(rState) ; 
    return ;
end

ns = baseNS ;
ns(indResolve) = 1 ;

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances

%%%%%%%% extractin new asset on the resolved state
for i=1:noi
    instance = h_cc(i,:);     
    % baseIns(indStay) = instance ;
    % baseIns(indResolve) = rState ;    
    baseIns = instance ;
    baseIns(indResolve) = rState ;    
    posBase = find_linearIndex_from_mat(baseNS,baseIns);
    temp_asset(i) = asset(posBase) ;
end

%asset = reshape(temp_asset,[noi 1])  ;
asset = reshape(temp_asset,ns)  ;



