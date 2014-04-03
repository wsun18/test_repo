function bar_score = bf_scoreEV_exclude(model,jp,asset,Targ,targ,Assm,assm)
% This is to calculate the expected score given conditions (Assm=assm)
% 9/16/2012, wsun

if nargin < 6
    Assm = {} ;
    assm = [] ;
end

if nargin < 5
    error('Number of arguments has to be at least 5') ;
end

node_names = model.node_names ;
ns = model.sizes ;

if ~isempty(Assm)
    indAssm = [] ;
    for k=1:length(condVar)
        indAssm = [indAssm findindex4stringcell(node_names, Assm{k})] ;
    end
end
indTarg = findindex4stringcell(node_names, Targ) ;

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances

k=1 ;
if ~isempty(Assm)
    for i=1:noi
        instance = h_cc(i,:);           
        if isequal(instance(indAssm),assm) 
            if instance(indTarg) ~= targ
                sub_prob(i) = jp(i) ;
                sub_asset(k) = asset(i) ;        
                k = k + 1 ;
            end    
        end
    end
else
    for i=1:noi
        instance = h_cc(i,:);           
        if instance(indTarg) ~= targ
            sub_asset(k) = asset(i) ;        
            sub_prob(k) = jp(i) ;
            k = k+1 ;
        end    
    end
end


sub_prob = sub_prob/sum(sub_prob) ;
bar_score = sum(sub_prob .* sub_asset) ;

