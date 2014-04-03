%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% *************************************************************
function asset = bf_asset_update(jp_after,jp_before,asset0)
% This is to update the asset table using LMSR.
% 9/19/2012,wsun

global b log_base ;

if log_base==2
    asset = asset0 + b*log2(jp_after ./ jp_before) ;
    return ;
end

if log_base == exp(1)
    asset = asset0 + b*log(jp_after ./ jp_before) ;
    return ;
end

error('You have to specify a log base value or something else is wrong') ;

