
% Aug.2, 2009
% Based on CPD_to_lambda_ukf
% This function is to handle the case for a continuous node that has both
% discrete and continuous parents. This function compute the lambda message
% sent from the continuous node to one of its parent, which is either a
% discrete parent or a continuous parent.

function lam_msg = CPD_to_lambda_mix(CPD, ps, lambda, pi_from_parent, p) ;
% ps: all parents nodes of the current node, assume that the first element
% in ps is the only discrete parent.
% p: the one parent we are sending lambda message.

% CPD.cps is the index for cts parents, not the real domains.
% To find the index of the excepted parent to which we are sending lambda
% messages among all cts parents. 

% The first element in 'pi_from_parent' is for the only discrete parent.

cps = ps(CPD.cps);   % continuous parents
cpsizes = CPD.sizes(CPD.cps);
self_size = CPD.sizes(end);
i = find_equiv_posns(p, cps); % p is the current node's i'th cts parent
psz = cpsizes(i);

if all(lambda.precision == 0) % no info to send 
    if p==ps(1) %for message sending to the only discrete parent
        lam_msg = ones(CPD.sizes(1),1);
    else % for other continuous parents
        lam_msg.precision = zeros(psz, psz);
        lam_msg.info_state = zeros(psz, 1);
    end
    return;
end

mixing_prior = pi_from_parent{1} ;
temp_pi_from_parent = pi_from_parent(2:end) ;

if isinf(lambda.precision) % current node,from which lambda message is sent, is observed.
    temp_lam.Sigma = zeros(self_size, self_size); % infinite precision => 0 variance
    temp_lam.mu = lambda.mu; % observed_value;
else
    temp_lam.Sigma = inv(lambda.precision);
    temp_lam.mu = temp_lam.Sigma * lambda.info_state;
end
 
if p==ps(1) % for lambda message sending to its sole discrete parent   
    for i=1:length(mixing_prior)
        tempCPD = CPD ;
        tempCPD.mean = CPD.mean(i);
        tempCPD.cov = CPD.cov(:,:,i);
        tempCPD.function = CPD.function(i);    
        tempCPD.dps = [];
        tempCPD.cps = CPD.cps - 1 ;
        tempCPD.sizes = CPD.sizes(2:end);
        
        temp_pi(i) = CPD_to_pi_ukf(tempCPD, temp_pi_from_parent);
        lam_msg(i) = int_prod_gaussian(temp_lam, temp_pi(i));
    end
    lam_msg = lam_msg' ;
    return;
end
 
% for computing lambda message sending to its continuous parent
ps = ps(2:end) ;
for i=1:length(mixing_prior)
    tempCPD = CPD ;
    tempCPD.mean = CPD.mean(i);
    tempCPD.cov = CPD.cov(:,:,i);
    tempCPD.function = CPD.function(i);    
    tempCPD.dps = [];
    tempCPD.cps = CPD.cps - 1 ;
    tempCPD.sizes = CPD.sizes(2:end);
    
    tp_lam(i) = CPD_to_lambda_ukf_inv(tempCPD, ps, lambda, temp_pi_from_parent, p);
end
 
lam_mu = 0 ;
tp_sigma = 0 ;
for j=1:length(mixing_prior)
    lam_mu = lam_mu + mixing_prior(j)*tp_lam(j).mu ;
    tp_sigma = tp_sigma + mixing_prior(j)*tp_lam(j).Sigma + ...
        mixing_prior(j)*(tp_lam(j).mu)^2 ;
end
lam_sigma = tp_sigma - lam_mu^2 ;

lam_msg.precision = inv(lam_sigma) ;
lam_msg.info_state = lam_mu * lam_msg.precision ;

 
 
 
 
