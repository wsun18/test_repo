
% Aug.2, 2009
% Based on CPD_to_lambda_ukf
% This function is to handle the case for a continuous node that has both
% discrete and continuous parents. This function compute the lambda message
% sent from the continuous node to one of its parent, which is either a
% discrete parent or a continuous parent.

function lam_msg = CPD_to_lambda_mix_gmm(CPD, ps, lambda, pi_from_parent, p) ;
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
        lam_msg.weight = lambda.weight ;
        lam_msg.ratio = lambda.ratio;
        lam_msg.gmmprior = lambda.gmmprior;
        lam_msg.precision = zeros(psz, psz);
        lam_msg.info_state = zeros(psz, 1);        
    end
    return;
end

disc_weight = pi_from_parent{1}' ;
size_dp = length(disc_weight); % size of discrete parent (assume only one discrete parent).
%noc_lam = length(lambda.gmmprior); % number of Gaussian components in self-node's lambda value.
temp_pi_from_parent = pi_from_parent(2:end) ;

% if isinf(lambda.precision) % current node,from which lambda message is sent, is observed.
%     temp_lam.gmmprior = lambda.gmmprior;
%     temp_lam.weight = lambda.weight;
%     temp_lam.Sigma = zeros(self_size, self_size); % infinite precision => 0 variance
%     temp_lam.mu = lambda.mu; % observed_value;
% end
 
if p==ps(1) % for lambda message sending to its sole discrete parent      
    temp_lam.Sigma = (lambda.precision) .^(-1);
    temp_lam.mu = lambda.info_state .* temp_lam.Sigma; 
    temp_lam.weight = lambda.weight;
    temp_lam.ratio = lambda.ratio;
    temp_lam.gmmprior = lambda.gmmprior;
    for i=1:size_dp
        tempCPD = CPD ; %must be Object of Gaussian CPD?, 2/15/10, wsun.
        tempCPD.mean = CPD.mean(i);
        tempCPD.cov = CPD.cov(:,:,i);
        tempCPD.function = CPD.function(i);    
        tempCPD.dps = [];
        tempCPD.cps = CPD.cps - 1 ;
        tempCPD.sizes = CPD.sizes(2:end);
        
        temp_pi(i) = CPD_to_pi_pcp_gmm(tempCPD, temp_pi_from_parent); %%9/30/09, 6:20pm.
        lam_msg(i) = int_prod_gaussian_gmm(temp_lam, temp_pi(i));
    end
    lam_msg = normalise(lam_msg') ;
    return;
end
 
% for computing lambda message sending to its continuous parent
ps = ps(2:end) ;
for i=1:size_dp
    tempCPD = CPD ;
    tempCPD.mean = CPD.mean(i);
    tempCPD.cov = CPD.cov(:,:,i);
    tempCPD.function = CPD.function(i);    
    tempCPD.dps = [];
    tempCPD.cps = CPD.cps - 1 ;
    tempCPD.sizes = CPD.sizes(2:end);
    
    tp_lam = CPD_to_lambda_pcp_gmm(tempCPD, ps, lambda, temp_pi_from_parent, p);
    noc_lam = length(tp_lam) ;
    for j=1:noc_lam
        lam_msg.precision((i-1)*noc_lam + j) = tp_lam.precision(j);
        lam_msg.info_state((i-1)*noc_lam + j) = tp_lam.info_state(j);
        %lam_msg.mu((i-1)*noc_lam + j) = tp_lam.mu(j);
        %lam_msg.Sigma((i-1)*noc_lam + j) = tp_lam.Sigma(j);
        lam_msg.weight((i-1)*noc_lam + j) = disc_weight(i) * tp_lam.weight(j);
        lam_msg.ratio((i-1)*noc_lam + j) = tp_lam.ratio(j);
    end
end

lam_msg.gmmprior = lam_msg.weight .* lam_msg.ratio ;
%lam_msg.gmmprior = lam_msg.gmmprior/sum(lam_msg.gmmprior);
 
