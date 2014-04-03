function subapot = ASSET_project_to_subdomain(apot,subdom)

%% This is to compute the asset over its sub domain from the
%% original asset table
%% -wsun, 3/6/2013.

assert(mysubset(subdom, apot.domain)) ;

%subapot = marginalize_assetpot(apot,subdom) ;


bigdom = apot.domain ;
sum_over = mysetdiff(bigdom,subdom) ;

bigT = apot.T ;
bigsz = apot.sizes ;

ndx = find_equiv_posns(sum_over, bigdom) ;
smallT = bigT ;
for i=1:length(ndx)
    if (sum(diff(smallT,1,ndx(i))) == 0)
        smallT = sum(smallT, ndx(i))/2;
    else
        error('@@@wsun: Asset Marginalization error - The asset table can not be marginalized because of stranded asset') ;
    end
end

ns = zeros(1, max(bigdom));
%ns(bigdom) = mysize(bigT); % ignores trailing dimensions of size 1
ns(bigdom) = bigsz;

smallT = squeeze(smallT); % remove all dimensions of size 1
ssz = ns(subdom) ;
if length(find(ssz>1)) > 1
    smallT = myreshape(smallT, ssz(find(ssz>1))); % put back relevant dims of size 1
else
    smallT = myreshape(smallT, [ssz(find(ssz>1)) 1]); 
end

subapot = dpot(subdom, ssz, smallT) ;


