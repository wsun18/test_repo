

% 04/17/2006

function ICPD = compute_icpd(lambda, CPD)
% compute the ICPD for node X based on lambda(X) and 
% the CPD of X given its parents.
%
% lambda has two fields: "precision" and "info_state"
% CPD has two or three fields: "mu", "cov", "weights"
%
% the returned ICPD has two or three fields: "mu", "cov", "weights" 


pi_precision = inv(CPD.cov) ;

ICPD.cov = inv(pi_precision + lambda.precision) ;

ICPD.mu = ICPD.cov * (pi_precision * CPD.mu + lambda.info_state) ;

if isfield(CPD, 'weights') && length(CPD.weights)
    ICPD.weights = ICPD.cov * pi_precision * CPD.weights  ;
end


