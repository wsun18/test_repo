function [p jp cc s] = mktinit(nv)
% nv is number of variables in the domain. we assume that all variables
% have binary outcomes, and they are independent with each other.


p = .5 * ones(2,nv) ;

%addpath('C:\wsun_workanywhere\Dropbox\myResearch\matlab\wsun_lib') ;
ns = 2*ones(1,nv) ;
cc = full_combination(ns) ;

N = 2^nv; 
for i=1:N
    tp = p(cc{i,1},1) ;
    for j=2:nv
        tp = tp*p(cc{i,j},j) ;
    end
    jp(i) = tp;
end

jp = jp' ; % make it into a column vector
s = 1000 * ones(N,1) ;

    