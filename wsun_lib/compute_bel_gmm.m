
% Nov.30, 2006

function bel = compute_bel_gmm(pi, lambda) 
 % compute the belief based on 'pi' and 'lambda' messages.
 % pi: mu and Sigma; lambda: precision and info_state.
 
 if isinf(lambda.precision) % ignore pi because lambda is completely certain (observed)
     bel.mu = lambda.mu;
     bel.Sigma = zeros(length(bel.mu)); % infinite precision => 0 variance
     return ;
 elseif all(pi.Sigma==0) % ignore lambda because pi is completely certain (delta fn prior)
     bel.Sigma = pi.Sigma;
     bel.mu = pi.mu;
     return ;
 elseif all(isinf(pi.Sigma)) % ignore pi because pi is completely uncertain
     bel.Sigma  = inv(lambda.precision);
     bel.mu = bel.Sigma * lambda.info_state;
     return ;
 elseif all(lambda.precision == 0) % ignore lambda because lambda is completely uncertain
     bel = combine_gmm(pi); % modified on 9/27/09, combine all Gaussian components into one single Gaussian.
     %bel.Sigma = pi.Sigma;
     %bel.mu = pi.mu;
     return ;
 else % combine both pi and lambda
     noc_pi = length(pi.gmmprior); % number of Gaussian components in pi. 9/30/09
     noc_lambda = length(lambda.weight); % number of Gaussian components in lambda.     
     
     lambda.Sigma = lambda.precision .^(-1);
     lambda.mu = lambda.Sigma .* lambda.info_state ;     
     for i=1:noc_pi
         pi_gc.mu = pi.mu(i); %gaussian component, 10/2/09.
         pi_gc.Sigma = pi.Sigma(i);
         for j=1:noc_lambda
             lam_gc.mu = lambda.mu(j);
             lam_gc.Sigma = lambda.Sigma(j);
             
             tp_bel = prod_2gaussian(pi_gc, lam_gc);              
             nconst = int_prod_gaussian(pi_gc,lam_gc); %normalization constant when multiply two Gaussians.
             tp_mixing = nconst * pi.gmmprior(i) * lambda.ratio(j) * lambda.weight(j) ; %-wsun,11/22/10.
             %tp_mixing = nconst * pi.gmmprior(i) * lambda.gmmprior(j) ;             
             gm_bel.gmmprior((i-1)*noc_lambda + j) = tp_mixing ;
             gm_bel.mu((i-1)*noc_lambda + j) = tp_bel.mu;
             gm_bel.Sigma((i-1)*noc_lambda + j) = tp_bel.Sigma;
         end
     end 
     gm_bel.gmmprior = gm_bel.gmmprior/sum(gm_bel.gmmprior); %normalization. 10/6/09
     bel = combine_gmm(gm_bel);     
     return ;
 end
 
 % if get here, there is an error.
 error('function error: compute_bel_gauss. - WSUN') ;