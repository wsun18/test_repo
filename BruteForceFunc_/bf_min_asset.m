function minAsset = bf_min_asset(model,asset,condVar, condState)
% This is to find the conditional minimum asset from the global asset
% table. 
% 9/16/2012, wsun

if nargin < 3
    minAsset = min(asset) ;
    return ;
elseif nargin ~= 4
    error('Number of arguments has to be 4 if given condition');
end

node_names = model.node_names ;
ns = model.sizes ;

indCondVar = [] ;
for k=1:length(condVar)
    indCondVar = [indCondVar findindex4stringcell(node_names, condVar{k})] ;
end

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances

k=1 ;
for i=1:noi
    instance = h_cc(i,:);   
    if isequal(instance(indCondVar),condState)
        sub_asset(k) = asset(i) ;        
        k = k + 1 ;
    end    
end
minAsset = min(sub_asset) ;