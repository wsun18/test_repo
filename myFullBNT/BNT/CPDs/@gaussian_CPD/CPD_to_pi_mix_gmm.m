
% Nov.27, 2006
% I put this function in the 'gaussian_CPD' directory so that it is easy to
% invoke the parameters from the CPD.

function pi = CPD_to_pi_mix_gmm(CPD, pi_from_parent) ;
%% assume only one discrete parent is allowed for this continuous node, and
%% this discrete parent is located in the first place in 'pi_from_parent'.
%% and it is assumed that only one continuous parent too for this
%% continuous node, located at the second index of parents list. 
%% 9/28/09.

mixing_prior = pi_from_parent{1} ;
%temp_pi_from_parent = pi_from_parent(2:end);

gmmprior = mixing_prior * pi_from_parent{2}.gmmprior ;
gmmprior = reshape(gmmprior', 1, length(mixing_prior)*length(pi_from_parent{2}.gmmprior));
noc = length(pi_from_parent{2}.gmmprior); % number of Gaussian components.

for i=1:CPD.sizes(1)
    tempCPD = CPD ;
    tempCPD.mean = CPD.mean(i);
    tempCPD.cov = CPD.cov(:,:,i);
    tempCPD.function = CPD.function(i);    
    tempCPD.dps = [];
    tempCPD.cps = CPD.cps - 1 ;
    tempCPD.sizes = CPD.sizes(2:end);

    for j=1:noc
        temp_pi_from_parent{1}.mu = pi_from_parent{2}.mu(j);
        temp_pi_from_parent{1}.Sigma = pi_from_parent{2}.Sigma(j);
        temp_pi((i-1)*noc+j) = CPD_to_pi_ukf(tempCPD, temp_pi_from_parent);
    end
end

pi.gmmprior = gmmprior;
for k=1:length(gmmprior)
    pi.mu(k) = temp_pi(k).mu ;
    pi.Sigma(k) = temp_pi(k).Sigma;
end

% combine GMM into one single Gaussin, 2/15/10, wsun.
% pi = combine_pi_gmm(pi) ;




