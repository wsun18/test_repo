function subapot = marginalize_assetpot(apot,subdom)

% This is to "marginalize" an asset table to its sub-domain. Theoretically,
% asset can not be marginalized from the joint states to its sub-domain
% (usually stranded), unless the states that being marginalizing over
% provide same assets. 

% -wsun, 3/6/2013.

bigdom = apot.domain ;
sum_over = mysetdiff(bigdom,subdom) ;

bigT = apot.T ;

ndx = find_equiv_posns(sum_over, bigdom) ;
smallT = bigT ;
for i=1:length(ndx)
    if sum(diff(smallT,1,ndx(i))) == 0)
        smallT = sum(smallT, ndx(i))/2;
    else
        disp('This asset table can not be marginalized!!!') ;
    end
end