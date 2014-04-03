
% -wsun, Nov. 16, 2010.
% modified code to have it capable to handle more than one discrete parents
% for continuous node.

%% -wsun, Aug.4, 2009
%% this function is for computing the pi message for a continuous node
%% which has only one parent and this only parent is discrete variable. 

function pi = CPD_to_pi_pdp(CPD, pi_from_parent) ;

mixing_prior = pi_from_parent{1}' ;

mean = CPD.mean ;
for i=1:CPD.sizes(1)
    cov(i) = CPD.cov(:,:,i) ;
end

mean2 = mean.^2 ;
cov2 = cov.^2 ;

pi.mu = sum(mixing_prior .* mean) ;
pi.Sigma = sum(mixing_prior .* cov2) + sum(mixing_prior .* mean2) - (pi.mu)^2 ;

