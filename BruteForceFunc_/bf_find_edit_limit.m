function [lbd ubd minq1 minq2] = bf_find_edit_limit(model,jp,user,Targ,targ,Assm,assm) ;

global b log_base ; %defined only once, was defined in main function

if nargin < 5, error('It has to have at least 5 arguments'); end
if nargin < 6, Assm = {}; assm=[]; end

asset = user.asset ;
% Given Assm=assm, and Targ=targ
assm = reshape(assm,[1 length(assm)]) ;
minAsset1 = bf_min_asset(model,asset,[Assm Targ],[assm targ]) ;

% Given Assm=assm, and Targ~=targ
minAsset2 = bf_min_asset_exclude(model,asset,Targ,targ,Assm,assm) ;

margTarg = bf_find_currProb(model,jp,Targ,Assm,assm);

lbd = margTarg(targ) * log_base^(-minAsset1/b) ;     % lower edit bound
ubd = 1 - (1-margTarg(targ)) * log_base^(-minAsset2/b) ; % upper edit bound
