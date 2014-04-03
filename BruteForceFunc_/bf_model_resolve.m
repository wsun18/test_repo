function model = bf_model_resolve(base_model,RVar) 
% This is to update the model after resolving a question
% 8/26/2013, wsun



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
    return ;
end

model.node_names = stayVar ;
model.sizes = baseNS(indStay) ;

