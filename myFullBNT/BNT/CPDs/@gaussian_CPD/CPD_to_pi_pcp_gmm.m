
% 9/28/09
% I put this function in the 'gaussian_CPD' directory so that it is easy to
% invoke the parameters from the CPD.

function pi = CPD_to_pi_pcp_gmm(CPD, pi_from_parent) ;
%% This function is to compute pi value of a continuous node which has only
%% continuous parent only (no matter how many), and the pi message sending 
%% from any continuous parent is in the format of GMM (Gaussian mixture model).
%% 3/8/10, wsun.

nocp = length(CPD.cps); % number of continuous parents.

for k = 1:nocp
    ngc(1,k) = length(pi_from_parent{k}.gmmprior); %number of Gaussian components. 
end

cc = full_combination(ngc);

for i=1:size(cc,1)    % i is index of each combination
    prior = 1 ;
    for j=1:length(cc(i,:)) % j is the index of continuous parents
        temp_pi_from_parent{j}.mu = pi_from_parent{j}.mu(cc{i,j}); %cc{i,j} is the index of Gaussian components.
        temp_pi_from_parent{j}.Sigma = pi_from_parent{j}.Sigma(cc{i,j}); 
        prior = prior * pi_from_parent{j}.gmmprior(cc{i,j});
    end
    temp_pi(i) = CPD_to_pi_ukf(CPD, temp_pi_from_parent);
    gmmprior(i) = prior ;
end

pi.gmmprior = gmmprior;
for k=1:length(gmmprior)
    pi.mu(k) = temp_pi(k).mu ;
    pi.Sigma(k) = temp_pi(k).Sigma;
end


% pi_mu = 0 ;
% tp_sigma = 0 ;
% for j=1:length(mixing_prior)
%     pi_mu = pi_mu + mixing_prior(j)*temp_pi(j).mu ;
%     tp_sigma = tp_sigma + mixing_prior(j)*temp_pi(j).Sigma + ...
%         mixing_prior(j)*(temp_pi(j).mu)^2 ;
% end
% 
% pi.mu = pi_mu ;
% pi.Sigma = tp_sigma - (pi.mu)^2 ;

