function p_new = proportional_adjust_prob(p,targ,q)
% This is to proportionally adjust the original probabilities on the states
% other than the state being specified. 
% 'p' is the original probability distribution
% 'targ' is the state being edited, 'q' is the probability such as 
% p_new(targ) = q

% 9/25/2012, wsun

p_new(targ) = q ;
change = q - p(targ)  ;
sub_sum = 1 - p(targ) ;

for i=1:length(p)
    if i ~= targ
        p_new(i) = p(i) - change * p(i)/sub_sum ;
    end
end

p_new = reshape(p_new,[length(p_new),1]) ;

p_new = round(p_new * 1000000)/1000000 ;
p_new(end) = 1-sum(p_new(1:end-1)) ; % to make sure summing up to 1

%p_new = p_new/sum(p_new) ;

