function obs = gen_obs_from_dist(dist) 
% This is to generate a discrete state from the specified discrete
% distribution 'dist'
% -wsun, 3/31/2013

a = rand() ;
dist_cdf = makd_CDF_from_dist(dist) ;
qset = find(dist_cdf > a) ;
obs = qset(1) ;



% ------------
function dist_cdf = makd_CDF_from_dist(dist) 

dist_cdf(1) = dist(1) ;

for i=2:length(dist) 
    dist_cdf(i) = dist_cdf(i-1) + dist(i) ;
end
