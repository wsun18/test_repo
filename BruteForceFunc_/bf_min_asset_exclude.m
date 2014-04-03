function minAsset = bf_min_asset_exclude(model,asset,excludeVar,excludeState,condVar,condState)
% This is to find the minimum asset from the global asset table given
% condVar=condState, but excludeVAr != excludeState
% Note that 'excludeVar' is a single variable, but 'condVar' can be a set of
% variables.

% 9/16/2012, wsun

if nargin < 5
    condVar = {};
    condState = [] ;
end

if nargin < 4
    error('Number of arguments has be at least 4');
end

node_names = model.node_names ;
ns = model.sizes ;

if ~isempty(condVar)
    indCondVar = [] ;
    for k=1:length(condVar)
        indCondVar = [indCondVar findindex4stringcell(node_names, condVar{k})] ;
    end
end
indExcludeVar = findindex4stringcell(node_names, excludeVar) ;

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances

k=1 ;
if ~isempty(condVar)
    for i=1:noi
        instance = h_cc(i,:);           
        if isequal(instance(indCondVar),condState) 
            if instance(indExcludeVar) ~= excludeState
                sub_asset(k) = asset(i) ;        
                k = k + 1 ;
            end    
        end
    end
else
    for i=1:noi
        instance = h_cc(i,:);           
        if instance(indExcludeVar) ~= excludeState
            sub_asset(k) = asset(i) ;        
            k = k+1 ;
        end    
    end
end

minAsset = min(sub_asset) ;

