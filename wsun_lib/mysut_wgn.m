
% Nov.28, 2006

function [post post_sp wc] = mysut_wgn(mu, Sigma, func, func_var, Q) ; 
% scaled unscented transformation from many to one. "wgn" means white
% gaussian noise.
% 'prior' has two field, 'mu' and 'cov'
% 'func' is the function has >=1 arguments but only one return. 
% 'post' has two field too, 'mu' and 'cov'

if nargin < 5, Q=0; end

% check if any variable has 0 variance.
DP = diag(Sigma) ;
% if 0 is not in DP, oi=0, otherwise, oi is the index of variables 
% with 0 variance.
oi = find_index(0, DP);  

% index of hidden variables.
hi = find(DP) ; %find: find indices of nonzero elements.

% % In the inverse function of CPD function, self node is always the last
% % variable.
% lambda_Sigma = Sigma(end,end) ;  

% if one or more variables are observed, or almost sure 
% with variance close to 0. 
%if rcond(Sigma) < 1e-3 
if ~isempty(oi)
    Sigma = Sigma(hi,hi) ;
    obs_mu = mu(oi) ;
    mu = mu(hi,1) ;
    obs = 1 ;  % observations found
else 
    obs = 0 ;  % everything is normal, no observations found
end    

% SUT parameters setting:
alpha=1 ; beta=2; kappa=0 ;
L = length(mu) ;  % number of dimensions of prior
lambda = alpha^2*(L + kappa) - L ;
gamma = sqrt(L + lambda) ;

% Note: In Matlab, 'chol' returns the upper triangular matrix instead of
% the lower triangular one so I transpose it (we need the lower triangular
% one as the square root, so r*r'=A). See page 85 in the book by
% Michael T. Heath: 'Scientific Computing, An Introduction Survey', 2ed.
% I used 'chol' directly at the beginning (not transpose the answer) and 
% It has been mading me so painful to find the reason why the returned
% Sigma was not exact for the linear function (it should be as claimed by
% using unscented transformation in several papers, such as on p53 in Rudolph
% Merwe's PhD dissertation.) The fact that there is no problem found with
% the diagnal covariance matrix (if the prior covariance matrix is diagonal
% which means no correlation between variables, then the returned variance
% is exact for linear function.) leaded me to doubt the 'chol' function in
% matlab. After I transpose it, everything is correct now. 
% (Nov.29,2006) - WSUN
S = gamma * chol(Sigma)' ;  % must transpose the returned answer of 'chol()'.

% sigma-points generation, (2*L + 1) sigma points in total.
nsp = 2*L +1 ;
sp(hi,1) = mu ;
for i=2:L+1
    sp(hi,i) = mu + S(:,i-1) ;
    sp(hi,i+L) = mu - S(:,i-1) ;        
end

if obs   % add the observations into sigma-point.
    sp(oi,:) = repmat(obs_mu, 1,nsp) ;
end

% associated weights for sigma-points
tf = lambda/(L+lambda) ;
wm = tf ;  % wm is weight for mean.
th = 0.5/(L+lambda) ;
wm(1,2:2*L+1) = repmat(th, 1, 2*L) ;
wc = wm ;  % wc is weight for cov.
wc(1,1) = tf + (1 - alpha^2 + beta) ;

% var = findsym(func) ;
% var_names = str2word(var) ;
for k=1:nsp    
    post_sp(:,k) = subs(func, func_var, sp(:,k)) ;    
end

post_mu = post_sp * wm' ; % mean after function transformation.

diff = post_sp - post_mu ;
diff2 = diff .^ 2 ;

P = diff2 * wc' ;


post.mu = post_mu ;
post.Sigma = P + Q ;    % white Gaussian noise is additive.


%%%%%%%%+++++++++++++++++++++++
function j = find_index(i, vt) 
 % i is one element in vt which is a vector
 % return j which is the index of i in vt.
 % assume there is only one i in vt, no repeat.
 % example is the best explanation
 % i=3, vt=[2 3 5]
 % then j=2.
 
 n=1 ; 
 for k=1:length(vt)
     if i == vt(k)
         j(n) = k ;
         n = n+1 ;
     end     
 end
 
 if n==1
     j = [] ; % if i is not in vt, j=0.
 end
 