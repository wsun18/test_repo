function [user, jp_current] = bf_makeTrade(model,user,jp_before,Targ,tProb,Assm,assm) 
% This is to update prob. and asset for the user who confirmed an edit on
% P(Targ|Assm=assm). Please note this is probability vector instead of a 
% single probability on one state. 
% 9/20/12, wsun

if nargin < 6, error('Number of arguments has to be at least 6'); end
if nargin < 7, Assm = {}; assm=[]; end

jp_after = bf_prob_update(model,jp_before,Targ,tProb,Assm,assm) ;
jp_current = jp_after ;

user.asset = bf_asset_update(jp_after,jp_before,user.asset) ;
user.cash = bf_min_asset(model,user.asset) ;
user.scoreEV = bf_scoreEV(model,jp_current,user.asset) ;
%user.scoreEV_Targ_state1 = bf_scoreEV(model,jp_current,user.asset,{Targ},1) ;
%user.scoreEV_Targ_NotState1 = bf_scoreEV_exclude(model,jp_current,user.asset,Targ,1) ;


