%% function to compute the effective sample size from a data set

function n = ess(w)

% w is the vector of weights

w  = w/sum(w) ;

n = 1/sum(w.^2) ;