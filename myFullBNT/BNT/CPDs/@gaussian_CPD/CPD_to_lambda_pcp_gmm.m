% updated on 3/17/2012, to correctly handle the case when continuous node
% is observed with multiple continuous parents.


% 9/28/09
% I put this function in the 'gaussian_CPD' directory so that it is easy to
% invoke the parameters from the CPD.

function lam_msg = CPD_to_lambda_pcp_gmm(CPD, ps, lambda, pi_from_parent, p) ;
%% This function is to compute the lambda message sent by one continuous
%% node to its sole pure continuous parent (pcp), and the message is represented
%% by a Gaussian mixture. 9/29/09.

if all(lambda.precision == 0) % no info to send 
    lam_msg = lambda ;
%     lam_msg.gmmprior = lambda.gmmprior;
%     lam_msg.ratio = lambda.ratio;
%     lam_msg.weight = lambda.weight ;
%     lam_msg.precision = zeros(psz, psz);
%     lam_msg.info_state = zeros(psz, 1);
    return;
end

cps = ps(CPD.cps);   % continuous parents
cpsizes = CPD.sizes(CPD.cps);
self_size = CPD.sizes(end);
icp = find_equiv_posns(p, cps); % p is the current node's i'th cts parent
psz = cpsizes(icp);

nocp = length(CPD.cps); % number of continuous parents.
% the continuous parent to whom lambda message is sending does not have
% influence on computing the message, so let us enforce it to have one fake
% componet with mu and Sigma as 0s.
pi_from_parent{icp}.gmmprior = 1 ; 
pi_from_parent{icp}.mu = 0 ; 
pi_from_parent{icp}.Sigma = 0 ; 

for k = 1:nocp
    ngc(1,k) = length(pi_from_parent{k}.gmmprior); %number of Gaussian components. 
end

cc = full_combination(ngc);
TC = size(cc,1); % number of total combinations.

% updated on 3/17/2012, to correctly handle the case when continuous node
% is observed with multiple continuous parents.
if isinf(lambda.precision) % current node,from which lambda message is sent, is observed.  
    for i=1:TC    % i is index of each combination of parents components
        prior = 1 ;
        for j=1:nocp % j is the index of continuous parents
            temp_pi_from_parent{j}.mu = pi_from_parent{j}.mu(cc{i,j}); %cc{i,j} is the index of Gaussian components.
            temp_pi_from_parent{j}.Sigma = pi_from_parent{j}.Sigma(cc{i,j}); 
            prior = prior * pi_from_parent{j}.gmmprior(cc{i,j});
        end
        tp_lam = CPD_to_lambda_ukf(CPD, ps, lambda, temp_pi_from_parent, p);    
        lam_msg.precision(i) = tp_lam.precision;
        lam_msg.info_state(i) = tp_lam.info_state;
        lam_msg.weight(i) = lambda.weight(1)*prior;
        %lamSigma = (lambda.precision) .^(-1) ;
        %tp_lamSigma = (tp_lam.precision)^(-1) ;
        lam_msg.ratio(i) = lambda.ratio(1) * tp_lam.ratio ; %need to be k as index for lambda, 12/15/10,wsun.
            %sqrt(tp_lamSigma/(lamSigma(i) + CPD.cov)) ;         
    end
    
    %lam_msg = CPD_to_lambda_ukf(CPD, ps, lambda, pi_from_parent, p); 
%     lam_msg.weight = 1;
%     lamSigma = inv(lam_msg.precision);
%     lam_msg.ratio = sqrt(lamSigma/(CPD.cov+) ;  % extra constant when transforming, 10/9/09.    
    return;
end

% current node not observed, but has some information to send. 
%% if the continuous node that sending lambda message is not observed, and
%% it is sending lambda message to one of its continuous parents, namely,
%% it has multiple continuous parents. 
noc_lam = length(lambda.weight) ; % number of components in lambda

for k=1:noc_lam % index of lambda components
    lam_gc.precision = lambda.precision(k);   % gc - Gaussian component. 9/29/09.
    lam_gc.info_state = lambda.info_state(k);    
    
    for i=1:TC    % i is index of each combination of parents components
        prior = 1 ;
        for j=1:nocp % j is the index of continuous parents
            temp_pi_from_parent{j}.mu = pi_from_parent{j}.mu(cc{i,j}); %cc{i,j} is the index of Gaussian components.
            temp_pi_from_parent{j}.Sigma = pi_from_parent{j}.Sigma(cc{i,j}); 
            prior = prior * pi_from_parent{j}.gmmprior(cc{i,j});
        end
        tp_lam = CPD_to_lambda_ukf(CPD, ps, lam_gc, temp_pi_from_parent, p);    
        lam_msg.precision((k-1)*TC + i) = tp_lam.precision;
        lam_msg.info_state((k-1)*TC + i) = tp_lam.info_state;
        lam_msg.weight((k-1)*TC + i) = lambda.weight(k)*prior;
        %lamSigma = (lambda.precision) .^(-1) ;
        %tp_lamSigma = (tp_lam.precision)^(-1) ;
        lam_msg.ratio((k-1)*TC + i) = lambda.ratio(k) * tp_lam.ratio ; %need to be k as index for lambda, 12/15/10,wsun.
            %sqrt(tp_lamSigma/(lamSigma(i) + CPD.cov)) ;         
    end
end

%lam_msg.gmmprior = lam_msg.weight .* lam_msg.ratio ;



