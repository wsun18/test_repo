function asset = bf_asset_extend_model(asset,base_model,big_model) 
% This is to update user's asset when extending the base_model to
% a bigger model. 
% 10/10/12, wsun

assert(~isempty(big_model.node_names)) ;
node_names = big_model.node_names ;
ns = big_model.sizes ;

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances

if ~isempty(base_model.node_names)
    baseVar = base_model.node_names ;
    indBase = [] ;
    for k=1:length(baseVar)
        indBase = [indBase findindex4stringcell(node_names, baseVar{k})] ;
    end  
    baseNS = ns(indBase) ;
    for i=1:noi
        instance = h_cc(i,:); 
        baseIns = instance(indBase) ;
        posBase = find_linearIndex_from_mat(baseNS,baseIns);
        temp_asset(i) = asset(posBase) ;
    end 
    asset = reshape(temp_asset,[noi 1]) ;
    return ;
end


% if base_model is empty
assert(length(asset) == 1) ;

%%%%%%%% extending asset to match bigger model
for i=1:noi
    temp_asset(i) = asset ;    
end

asset = reshape(temp_asset,[noi 1]) ;
