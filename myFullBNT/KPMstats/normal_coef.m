function c = normal_coef (Sigma)
% NORMAL_COEF Compute the normalizing coefficient for a multivariate gaussian.
% c = normal_coef (Sigma)

if 1
n = length(Sigma);
c = (2*pi*Sigma)^(-0.5);
end

if 0
n = length(Sigma);
c = (2*pi)^(-n/2) * det(Sigma)^(-0.5);
end
