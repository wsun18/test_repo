
% Nov.16, 2010 - wsun
% modified the previous code (pi = CPD_to_pi_mix_gmm(CPD, pi_from_parent))
% and changed the name to be 
%%%% function pi = CPD_to_pi_mixparents_gmm(CPD, pi_from_parent) %%%
% aiming to handle multiple discrete parents and continuous parents (more
% than one for each)

%% Sep. 28, 2009 - wsun
%% assume only one discrete parent is allowed for this continuous node, and
%% this discrete parent is located in the first place in 'pi_from_parent'.
%% and it is assumed that only one continuous parent too for this
%% continuous node, located at the second index of parents list. 


% Nov.27, 2006
% I put this function in the 'gaussian_CPD' directory so that it is easy to
% invoke the parameters from the CPD.

function pi = CPD_to_pi_mixparents_gmm(CPD, pi_from_parent) ;

% initialize pi
pi.gmmprior = [] ;
pi.mu = [] ;
pi.Sigma = [] ;

ns = CPD.sizes ;
nodp = length(CPD.dps) ;
nocp = length(CPD.cps) ;

dcc = full_combination(ns(1:nodp)) ; 

% in the order of index, discrete parents will be always prior to
% continuous parents and start from the first position.
for i=1:size(dcc,1)
    mixing_prior(i) = pi_from_parent{1}(dcc{i,1});
    for j=2:nodp
        mixing_prior(i) = mixing_prior(i) * pi_from_parent{j}(dcc{i,j});        
    end
    
    tempCPD = CPD ;
    tempCPD.mean = CPD.mean(i);
    tempCPD.cov = CPD.cov(i);
    tempCPD.function = CPD.function(i);    
    tempCPD.dps = [];
    tempCPD.cps = CPD.cps - nodp ;
    tempCPD.sizes = CPD.sizes(nodp+1:end);
    
    temp_pi_from_parent = pi_from_parent(nodp+1:end) ;
    
    temp_pi = CPD_to_pi_pcp_gmm(tempCPD, temp_pi_from_parent) ;
    
    temp_pi.gmmprior = mixing_prior(i) * temp_pi.gmmprior ;
    
    nogc = length(temp_pi.gmmprior) ; % number of gaussian components
    pi.gmmprior(end+1:end+nogc) = temp_pi.gmmprior ;
    pi.mu(end+1:end+nogc) = temp_pi.mu ;
    pi.Sigma(end+1:end+nogc) = temp_pi.Sigma ;  
end

% normalization
pi.gmmprior = pi.gmmprior/sum(pi.gmmprior) ;





