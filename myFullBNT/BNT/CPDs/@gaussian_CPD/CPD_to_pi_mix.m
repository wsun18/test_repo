
% Nov.27, 2006
% I put this function in the 'gaussian_CPD' directory so that it is easy to
% invoke the parameters from the CPD.

function pi = CPD_to_pi_mix(CPD, pi_from_parent) ;
%% assume only one discrete parent is allowed for this continuous node, and
%% this discrete parent is located in the first place in 'pi_from_parent'.

mixing_prior = pi_from_parent{1} ;
temp_pi_from_parent = pi_from_parent(2:end);

for i=1:CPD.sizes(1)
    tempCPD = CPD ;
    tempCPD.mean = CPD.mean(i);
    tempCPD.cov = CPD.cov(:,:,i);
    tempCPD.function = CPD.function(i);    
    tempCPD.dps = [];
    tempCPD.cps = CPD.cps - 1 ;
    tempCPD.sizes = CPD.sizes(2:end);
    
    temp_pi(i) = CPD_to_pi_ukf(tempCPD, temp_pi_from_parent);
end

pi_mu = 0 ;
tp_sigma = 0 ;
for j=1:length(mixing_prior)
    pi_mu = pi_mu + mixing_prior(j)*temp_pi(j).mu ;
    tp_sigma = tp_sigma + mixing_prior(j)*temp_pi(j).Sigma + ...
        mixing_prior(j)*(temp_pi(j).mu)^2 ;
end

pi.mu = pi_mu ;
pi.Sigma = tp_sigma - (pi.mu)^2 ;

