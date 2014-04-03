
% Nov.27, 2006
% I put this function in the 'gaussian_CPD' directory so that it is easy to
% invoke the parameters from the CPD.

function lam_msg = CPD_to_lambda_ukf(CPD, ps, lambda, pi_from_parent, p) ;
 % ps: all parents nodes of the current node.
 % p: the one parent we are sending lambda message.

 % CPD.cps is the index for cts parents, not the real domains.
 % To find the index of the excepted parent to which we are sending lambda
 % messages among all cts parents:
 cps = ps(CPD.cps);   % continuous parents
 cpsizes = CPD.sizes(CPD.cps);
 self_size = CPD.sizes(end);
 i = find_equiv_posns(p, cps); % p is the current node's i'th cts parent
 psz = cpsizes(i);  
 
 if all(lambda.precision == 0) % no info to send 
     lam_msg.weight = 1 ;
     lam_msg.ratio = 1 ;
     lam_msg.precision = zeros(psz, psz);
     lam_msg.info_state = zeros(psz, 1);
     return;
 end
 
 Q = CPD.cov ;
 f = CPD.function{1} ;  % CPD function of parents to obtain the value of the child.
 
 %% find the coefficient of the independent variable in the original linear
 %% equation - the final ratio will be the reciprocal of this number. 
 %% -wsun, 12/14/10.  
 %cps_var = findsym(f) ; % continuous parents.
 cps_var = CPD.variables(1:end-1) ; % continuous parents.
 v = zeros(length(cps_var),1) ;
 v(i,1) = 1 ;
 if isempty(CPD.nonlinear)  % calculate 'r' only when CPD function is not nonlinear
     r = sqrt(subs(f,cps_var,v)^2) ;
 end
 % cps_names = str2word(cps_var) ;  
 
 f = f + sym('noise') ;  % extend the function to include noise term.
 
 % inverse function of the CPD function to obtain the value of one parent
 % (the one being excepted)
 independent_var = CPD.variables{i} ;
 g = finverse(f, independent_var) ; 
 g = subs(g, independent_var, 'self') ;
 k = 1 ;
 for j=1:length(CPD.variables)-1
     if j ~= i
         g_var{k} = CPD.variables{j} ;
         k = k+1 ;
     end
 end
 g_var{k} = 'noise' ;
 g_var{end+1} = 'self' ;
%  g_var = myfindsym(g) ;
%  g_var_names = str2word(g_var) ;
 
 % transform the lambda message of the current node.
 precision = lambda.precision  ;
 if isinf(precision) % current node,from which lambda message is sent, is observed.
     Sigma_lambda = zeros(self_size, self_size); % infinite precision => 0 variance
     mu_lambda = lambda.mu; % observed_value;
 else
     Sigma_lambda = inv(precision);
     mu_lambda = Sigma_lambda * lambda.info_state;
 end
 
 % augment 'mu' and 'Sigma':
 i=1 ;
 for k=1:length(cps) % only get pi msgs from cts parents
     pk = cps(k);
     if pk ~= p  % except the one parent to which we are sending lambda message.      
         m = pi_from_parent{k} ;      
         augmu(i,1) = m.mu ;
         augSigma(i,i) = m.Sigma ;
         i=i+1 ;
     end
 end
 
 % augment to include the noise term
 %augmu(i,1) = 0 ;
 augmu(i,1) = CPD.mean ;
 augSigma(i,i) = Q ;
 i=i+1 ;
 
 % augment to include lambda
 augmu(i,1) = mu_lambda ;
 augSigma(i,i) = Sigma_lambda ;
 
%  if rcond(augSigma) < 1e-3  % if the prior is almost sure (variance close to 0).
%      post_mu = subs(g, g_var_names, augmu) ;
%      post_Sigma = Q ;
%      
%      lam_msg.precision = inv(post_Sigma) ;
%      lam_msg.info_state = post_mu * lam_msg.precision ;
%      return ;
%  end
 
 % scaled unscented transformation from child to parent.
 temp_lam = mysut_wgn(augmu, augSigma, g, g_var) ;  % Note here dont have Q as argument.
 
 %lam_msg = temp_lam;
 lam_msg.weight = 1;
 %lam_msg.ratio = sqrt(temp_lam.Sigma/trace(augSigma)) ;  % extra constant when transforming, 10/9/09.    
 %% -wun, 10/14/10, for linear function, the ratio is simply the 
 %% reciprocal of the sqrt of the square of the linear coefficient of the
 %% corresponding variable in the original CPD function:
 if CPD.nonlinear==1
      lam_msg.ratio = sqrt(temp_lam.Sigma)/sqrt(CPD.cov + Sigma_lambda) ;
 else
     lam_msg.ratio = 1/r ;
 end
 lam_msg.precision = inv(temp_lam.Sigma) ;
 lam_msg.info_state = temp_lam.mu * lam_msg.precision ;
 
 
 