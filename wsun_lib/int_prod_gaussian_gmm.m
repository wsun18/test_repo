
function intp = int_prod_gaussian_gmm(g1, g2)
%% integration of two Gaussian mixture over the same argument, based on
%% function "intp = int_prod_gaussian(g1,g2). 10/1/09.
%% Integration result will be still a non-negative constant. 

%% assume both 'g1' and 'g2' are Gaussian mixtures, represented by
%% struct with three fields - gmmprior, mu and Sigma. Besides, 'g1' is
%% designed to represent lambda message for continuous node, and so it 
%% has one more field called ratio, because lambda message is not 
%% real Gaussian distribution, instead, lambda message always has some coefficient. 
%% 10.12.2009

noc_g1 = length(g1.gmmprior); %number of components in g1;
noc_g2 = length(g2.gmmprior); 

intp = 0;
for i=1:noc_g1    
    for j=1:noc_g2
        %product of mixing prior (pmp). 10/1/09. adding ratio on 10/12/09.
        %pmp = g1.ratio(i) * g1.weight(i) * g2.gmmprior(j) ; 
        pmp = g1.gmmprior(i) * g2.gmmprior(j) ; 
        mu1 = g1.mu(i);
        mu2 = g2.mu(j);
        S1 = g1.Sigma(i);
        S2 = g2.Sigma(j);
        intp = intp + pmp * (1/sqrt(2*pi*(S1+S2))) * ...
            exp(-(mu1-mu2)^2/(2*(S1+S2))) ;
    end
end
        

% Sigma1 = g1.Sigma ;
% Sigma2 = g2.Sigma ;
% mu1 = g1.mu ;
% mu2 = g2.mu ;
% 
% intp = (1/sqrt(2*pi*(Sigma1+Sigma2))) * ...
%     exp(-(mu1-mu2)^2/(2*(Sigma1+Sigma2))) ;

%% formula derived in Appendix of my dissertation. 

