
function intp = int_prod_gaussian(g1, g2)
%% integration of two Gaussian pdf over the same argument is a non-negative
%% constant
%% wsun, Aug.3, 2009

%% assume both 'g1' and 'g2' are struct with two fields - mu and Sigma.

Sigma1 = g1.Sigma ;
Sigma2 = g2.Sigma ;
mu1 = g1.mu ;
mu2 = g2.mu ;

intp = (1/sqrt(2*pi*(Sigma1+Sigma2))) * ...
    exp(-(mu1-mu2)^2/(2*(Sigma1+Sigma2))) ;

%% formula derived in Appendix of my dissertation. 

