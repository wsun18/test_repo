function user = bf_update_scoreEV(model,user,jp_current) 
% This is to update all users' scoreEV, because whenever market probability
% changes, all active users' scoreEV change accordingly.

activeUser = find(~isemptycell(user)) ;
for k=1:length(activeUser)
    uInd = activeUser(k) ;
    user{uInd}.scoreEV = bf_scoreEV(model,jp_current,user{uInd}.asset) ;
end

