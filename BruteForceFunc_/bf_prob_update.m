%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% *************************************************************
function jp_after = bf_prob_update(model,jp_before,Targ,tprob,Assm,assm)
% This is the brute force method to calculate the joint probability in the
% most fundamental way, that relays on the original probability and the
% combo edit only, where the combo edit is Q(Targ=targ|Assm=assm)=tprob.

if nargin < 5, Assm={}; assm=[]; end

% find the current probability of P(Targ|Assm=assm)
cprob = bf_find_currProb(model,jp_before,Targ,Assm,assm) ; 

node_names = model.node_names ;
ns = model.sizes ;

if ~isempty(Assm)
    indAssm = [] ;
    for k=1:length(Assm)
        indAssm = [indAssm findindex4stringcell(node_names, Assm{k})] ;
    end
    assm = reshape(assm,[1,length(assm)]) ;
end
indTarg = findindex4stringcell(node_names, Targ);

h_cc = full_combination_new(ns) ;
noi = size(h_cc,1); % number of instances
jp_after = jp_before ;
% update the joint probability for all joint states
for i=1:noi
    instance = h_cc(i,:);   
    if ~isempty(Assm)
        if isequal(instance(indAssm),assm)
            targ_state = instance(indTarg) ;
            jp_after(i) = jp_before(i) * tprob(targ_state)/cprob(targ_state) ;
        end
    else
        targ_state = instance(indTarg) ;
        jp_after(i) = jp_before(i) * tprob(targ_state)/cprob(targ_state) ;
    end   
end


