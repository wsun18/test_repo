
% -wsun, Nov. 16, 2010.
% modified code to have it capable to handle more than one discrete parents
% for continuous node. And save the resulting pi in the format of GMM.
% Previous code always combine it into one single. 

%% -wsun, Aug.4, 2009
%% this function is for computing the pi message for a continuous node
%% which has only one parent and this only parent is discrete variable. 

function pi = CPD_to_pi_pdp_gmm(CPD, pi_from_parent) ;

nodp = length(pi_from_parent) ;
ns = CPD.sizes(1:nodp) ;
cc = full_combination(ns) ; 

for i=1:size(cc,1)
    mixing_prior(i) = pi_from_parent{1}(cc{i,1});
    for j=2:nodp
        mixing_prior(i) = mixing_prior(i) * pi_from_parent{j}(cc{i,j});        
    end
    pi.gmmprior(i) = mixing_prior(i) ;
    pi.mu(i) = CPD.mean(i) ;
    pi.Sigma(i) = CPD.cov(i) ;
end

% normalization
pi.gmmprior = pi.gmmprior/sum(pi.gmmprior) ;



% % mixing_prior = pi_from_parent{1}' ;
% % 
% % mean = CPD.mean ;
% % for i=1:CPD.sizes(1)
% %     cov(i) = CPD.cov(:,:,i) ;
% % end
% % 
% % mean2 = mean.^2 ;
% % cov2 = cov.^2 ;
% % 
% % pi.mu = sum(mixing_prior .* mean) ;
% % pi.Sigma = sum(mixing_prior .* cov2) + sum(mixing_prior .* mean2) - (pi.mu)^2 ;

