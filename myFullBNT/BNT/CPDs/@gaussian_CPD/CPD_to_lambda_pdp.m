

%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%
% -wsun, 11/21/10
% Modified code to have it generalized for being capable in handling
% whatever many discrete parents for a continuous node, but no continuous
% parents. 
%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%
% Aug.2, 2009
% Based on CPD_to_lambda_ukf
% This function is to handle the case for a continuous node that has only
% one parent that is discrete variable.
% This function compute the lambda message
% sent from the continuous node to its only and discrete parent.
%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%

function lam_msg = CPD_to_lambda_pdp(CPD, ps, lambda, pi_from_parent, p) ;
% ps: all parents nodes of the current node, assume that the first element
% in ps is the only discrete parent.
% p: the one parent we are sending lambda message.

% CPD.cps is the index for cts parents, not the real domains.
% To find the index of the excepted parent to which we are sending lambda
% messages among all cts parents. 

ip = find_equiv_posns(p, ps); % p is the ip'th parent for the current node.
dpsz = CPD.sizes(ip); 

if all(lambda.precision == 0) % no info to send 
    lam_msg = ones(dpsz,1);    
    return;
end

if isinf(lambda.precision) % current node,from which lambda message is sent, is observed.
    self_size = CPD.sizes(end);
    temp_lam.weight = lambda.weight ;
    temp_lam.ratio = lambda.ratio ;  
    temp_lam.mu = lambda.mu; % observed_value;
    temp_lam.Sigma = zeros(self_size, self_size); % infinite precision => 0 variance    
else
    temp_lam.weight = lambda.weight ;
    temp_lam.ratio = lambda.ratio ;    
    temp_lam.Sigma = lambda.precision .^ (-1);
    temp_lam.mu = temp_lam.Sigma .* lambda.info_state;
end

% for cases that this continuous node has some lambda information to send.
nodp = length(pi_from_parent) ;
ns = CPD.sizes(1:nodp) ;
cc = full_combination(ns) ; 

% initialization
for k=1:dpsz
    temp_pi(k).gmmprior = []; 
    temp_pi(k).mu = []; 
    temp_pi(k).Sigma = []; 
end

for i=1:size(cc,1)        
    mixing_prior(i) = 1;
    for j=1:nodp
        if ip ~= j
            mixing_prior(i) = mixing_prior(i) * pi_from_parent{j}(cc{i,j}); 
        end
    end
    temp_pi(cc{i,ip}).gmmprior(end+1) = mixing_prior(i) ;    
    temp_pi(cc{i,ip}).mu(end+1) = CPD.mean(i) ;
    temp_pi(cc{i,ip}).Sigma(end+1) = CPD.cov(i) ;
end

temp_lam.gmmprior = temp_lam.weight .* temp_lam.ratio ;
for k=1:dpsz
    lam_msg(k) = int_prod_gaussian_gmm(temp_lam, temp_pi(k));       
end

lam_msg = lam_msg' ;


