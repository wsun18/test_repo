function r = determine_asset_dependency(asset, given_dom, initAsset, b, log_base)
% This is to compute the ratio between states given one variable
% wsun, 3/25/2013

% For an asset table with size 3*2*2 like below, generated by a row of flat
% trades separately on A, B, C: 
% First trade:  B from [.5 .5] to [.6 .4] ;
% Second trade: C from [.5 .5] to [.45 .55];
% Third trade:  A from [.3333 .3333 .3333] to [.4 .25 .35] ;
% aT3(:,:,1) =
%   1.0e+002 *
%    1.37406571822254   0.78910321750138
%    0.69599381310990   0.11103131238874
%    1.18142064028014   0.59645813955899
% aT3(:,:,2) =
%   1.0e+002 *
%    1.66357233541752   1.07860983469637
%    0.98550043030488   0.40053792958373
%    1.47092725747513   0.88596475675397


if nargin < 3
    initAsset = 100 ;
end
if nargin < 4 
    b = 100 ;
    log_base = 2; 
end

bigdom = asset.domain ;
aT = asset.T ;
sum_over = given_dom ;
ndx = find_equiv_posns(sum_over, bigdom) ;

% leftT = diff(aT,1,ndx) ; % leftT contains the conditional asset for the 'given_dom'

% if (sum(leftT) == 0) % asset is independent with the given_dom
%     r = 0 ;
%     return ;
% end

rest = mysetdiff(bigdom,given_dom) ;
ldx = find_equiv_posns(rest,bigdom) ;
% ess = 10^(-8) ;
% for j=1:length(ldx)
%     checkT = diff(leftT,1,ldx(j)) ;
%     if sum(checkT(:)) < ess
%         r(j) = 0 ;
%     else
%         r(j) = 1 ;
%     end
% end


% re-shuffle the original asset table in the way that the index of the
% 'given_dom' goes first. For example, if the original domain is 'A,B,C',
% and size is '2*3*4', and the 'given_dom' is 'B', I then need to reshuffle
% the table as 'B,A,C', with the size as '3*2*4', accordingly.
ns = asset.sizes ;
rest_ns = ns(ldx) ;
new_ns = [ns(ndx) rest_ns] ;

cc = full_combination_new(new_ns) ;
noi = size(cc,1); % number of instances
% reshuffle the table
for i=1:noi
    instance = cc(i,:);   
    old_inst(ndx) = instance(1) ;
    old_inst(ldx) = instance(2:end) ;
    idx = find_linearIndex_from_mat(ns,old_inst) ;
    newaT(i) = aT(idx) ;
end

newaT = reshape(newaT,[ns(ndx) prod(rest_ns)]) ;

checkT = diff(newaT,1,ndx) ;
ess = 10^(-8) ;
if sum(diff(checkT,1,1)) < ess % the 'given_dom' is independent to other variables, so it may be summed out.
    jointDist = traceAssetBackToProb(checkT(1,:), b, log_base) ;
else
    error('Asset can not be marginalized over the given domain') ;
end

jointDist = reshape(jointDist,rest_ns) ;

initProb = (1/prod(rest_ns)) * ones(rest_ns) ;

if log_base == 2
    rest_aT = initAsset + b*log2(jointDist ./ initProb) ;
else
    error('Check your log base! We use 2 as the log base.') ;
end




