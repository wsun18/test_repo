
function bel = combine_gmm(gm)

%% combine all Gaussian components in a Gaussian mixture using one single
%% mean and variance to represent it. 
%% 9/29/09

%% assume argument 'gm' has three fields - 
%% .gmmprior - mixing prior
%% .mu - mean centers
%% .Sigma - covariances for each component


mixing_prior = gm.gmmprior ;

tp_mu = 0 ;
tp_sigma = 0 ;

for j=1:length(mixing_prior)
    tp_mu = tp_mu + mixing_prior(j)*gm.mu(j) ;
    tp_sigma = tp_sigma + mixing_prior(j)*gm.Sigma(j) + ...
        mixing_prior(j)*(gm.mu(j))^2 ;
end

bel.mu = tp_mu ;
bel.Sigma = tp_sigma - (tp_mu)^2 ;