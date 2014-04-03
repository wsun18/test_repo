function new_p = DAC_VP_calc_new_prob(p, tr, rr, p_c_percent) 
% This is to calculate the new probability distribution over the entire
% range based on probability change 'c_p' on 'tr'.
% tr: target_range
% rr: reference-range
% p: current probability distribution

assert(length(p) >= rr(end)) ;
assert(rr(end) >= tr(end)) ;
assert(rr(1) <= tr(1)) ;

tsi = tr(1)-rr(1)+1 ; % relative starting index of target inverval under reference interval.
tii = tsi:(tsi+(tr(end)-tr(1)+1)-1) ; % relative indices of target interval under reference interval.
crp = p(rr(1):rr(end))/sum(p(rr(1):rr(end))) ; % current absolute probability dist. of P(ref. intval.)
ctp = crp(tii) ; % current prob. distr. on target range given reference range is true.

c_p = sum(ctp) * p_c_percent ;

x = sum(ctp) + c_p ; % intending target prob. edit on the entire target range given reference range.

new_ctp = ctp * (x/sum(ctp)) ; % new prob. distr. over the target range after the edit.

crp_other = 1 - sum(ctp) ;  % the sum of probabilities over all other units in reference range than target range
x_other = crp_other - c_p ;
other_ratio = x_other/crp_other ; % the probability changing ratio for other units    

for i=1:length(crp)
    if ~mysubset(i, tii)
        new_crp(i) = crp(i) * other_ratio ;
    end
end

new_crp(tii) = new_ctp ; 

new_p = p ;
new_p(rr(1):rr(end)) = new_crp * sum(p(rr(1):rr(end))) ; % de-normalization.