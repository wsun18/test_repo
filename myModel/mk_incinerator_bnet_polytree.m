function bnet  = mk_incinerator_bnet_polytree(CPD_type)
% MK_INCINERATOR_BNET The waste incinerator emissions example from Cowell et al p145
% function bnet  = mk_incinerator_bnet(ns)
% 
% If ns is omitted, we use the scalars and binary nodes and the original params.
% Otherwise, we use random params of the desired size.
%
% Lauritzen, "Propogation of Probabilities, Means and Variances in Mixed Graphical Association Models", 
% JASA 87(420): 1098--1108
% This example is reprinted on p145 of "Probabilistic Networks and Expert Systems",
% Cowell, Dawid, Lauritzen and Spiegelhalter, 1999, Springer. 
% For a picture, see http://www.cs.berkeley.edu/~murphyk/Bayes/usage.html#cg_model

% node numbers
F=1; B=2; W=3; E=4; C=5; D=6; Min=7; Mout=8; L=9;
names = {'F', 'B', 'W', 'E', 'C', 'D', 'Min', 'Mout', 'L'};
n = 9;
dnodes = [F W B];
cnodes = mysetdiff(1:n, dnodes);

ns = ones(1, n) ;
ns(dnodes) = 2 ;

% node sizes - all cts nodes are scalar, all discrete nodes are binary
if nargin < 1 
    CPD_type = 'orig' ;    
end

if strcmp(CPD_type, 'gauss') || strcmp(CPD_type, 'nonlinear') 
    dnodes = [] ;
    cnodes = mysetdiff(1:n, dnodes);
    ns = ones(1,n) ;
    %rnd = 1 ;
end
   
if ~ismember(CPD_type, {'orig', 'orig4dmp', 'rndclg', 'gauss', ...
        'nonlinear', 'hybrid_nonlinear', 'hybrid_nonlinear_test'})
    error('Error, wrong CPD type: line 36') ;
end

if strcmp(CPD_type, 'hybrid_nonlinear')
    dnodes = [F B W] ;
    cnodes = mysetdiff(1:n, dnodes);
    ns = ones(1,n) ;
    ns(dnodes) = 2 ;
end
    
      
% topology (p 1099, fig 1)
dag = zeros(n);
dag(F,E)=1;
%dag(W,[E Min D]) = 1;
dag(W,Min) = 1;
dag(E,D)=1;
dag(B,[C D])=1;
dag(D,[L Mout])=1;
dag(Min,Mout)=1;

% params (p 1102)
bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', names);


switch CPD_type
    case 'orig',  
        bnet.CPD{B} = tabular_CPD(bnet, B, 'CPT', [0.85 0.15]); % 1=stable, 2=unstable
        bnet.CPD{F} = tabular_CPD(bnet, F, 'CPT', [0.95 0.05]); % 1=intact, 2=defect
        bnet.CPD{W} = tabular_CPD(bnet, W, 'CPT', [2/7 5/7]); % 1=industrial, 2=household
        bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', [-3.9 -0.4], ...
            'cov', [0.00002 0.0001]);
        bnet.CPD{D} = gaussian_CPD(bnet, D, 'mean', [6.5 6.0], ...
            'cov', [0.03 0.04], 'weights', [1 1]);
        bnet.CPD{C} = gaussian_CPD(bnet, C, 'mean', [-2 -1], 'cov', [0.1 0.3]);
        bnet.CPD{L} = gaussian_CPD(bnet, L, 'mean', 3, 'cov', 0.25, 'weights', -0.5);
        bnet.CPD{Min} = gaussian_CPD(bnet, Min, 'mean', [0.5 -0.5],...
            'cov', [0.01 0.005]);
        bnet.CPD{Mout} = gaussian_CPD(bnet, Mout, 'mean', 0, ...
            'cov', 0.002, 'weights', [1 1]);   
    case 'orig4dmp'
        bnet.CPD{B} = tabular_CPD(bnet, B, 'CPT', [0.85 0.15]); % 1=stable, 2=unstable
        bnet.CPD{F} = tabular_CPD(bnet, F, 'CPT', [0.95 0.05]); % 1=intact, 2=defect
        bnet.CPD{W} = tabular_CPD(bnet, W, 'CPT', [2/7 5/7]); % 1=industrial, 2=household
        bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', [-3.9 -0.4], ...
            'cov', [0.00002 0.0001]);
        bnet.CPD{D} = gaussian_CPD(bnet, D, 'mean', [6.5 6.0], ...
            'cov', [0.03 0.04], ...
            'function', {sym('E'), sym('E')}) ;
        bnet.CPD{C} = gaussian_CPD(bnet, C, 'mean', [-2 -1], 'cov', [0.1 0.3]);
        bnet.CPD{L} = gaussian_CPD(bnet, L, 'mean', 3, 'cov', 0.25, 'function', {sym('-0.5*D')});
        bnet.CPD{Min} = gaussian_CPD(bnet, Min, 'mean', [0.5 -0.5],...
            'cov', [0.01 0.005]);
        bnet.CPD{Mout} = gaussian_CPD(bnet, Mout, 'mean', 0, ...
            'cov', 0.002, 'function', {sym('D+Min')}); 
    case 'gauss'        
        for i=cnodes(:)'
            bnet.CPD{i} = gaussian_CPD(bnet, i);
        end
    case 'rndclg'
        for i=dnodes(:)'
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
        for i=cnodes(:)'
            bnet.CPD{i} = gaussian_CPD(bnet, i);
        end
    case 'nonlinear'
        bnet.CPD{F} = gaussian_CPD(bnet, F, 'mean', -10, 'cov', 3) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', 100, 'cov', 10) ;        
        bnet.CPD{B} = gaussian_CPD(bnet, B, 'mean', 50, 'cov', 5) ;
        bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', 0, 'cov', 1,...
            'function', sym('W + 2*F') ) ;
        bnet.CPD{C} = gaussian_CPD(bnet, C, 'mean', 0, 'cov', 3,...
            'function', sym('exp(B^(1/3))')) ;
        bnet.CPD{D} = gaussian_CPD(bnet, D, 'mean', 0, 'cov', 5,...
            'function', sym('sqrt(W)*log(E) - B') ) ;
        bnet.CPD{Min} = gaussian_CPD(bnet, Min, 'mean', 6, 'cov', 3,...
            'function', sym('sqrt(W)') ) ;       
        bnet.CPD{Mout} = gaussian_CPD(bnet, Mout, 'mean', 0, 'cov', 5,...
            'function', sym('0.5*D*Min') ) ;
        bnet.CPD{L} = gaussian_CPD(bnet, L, 'mean', 0, 'cov', 5,...
            'function', sym('-5*D')) ;    
    case 'hybrid_nonlinear'        
        bnet.CPD{F} = tabular_CPD(bnet, F, 'CPT', [0.95 0.05]); % 1=intact, 2=defect                
        bnet.CPD{B} = tabular_CPD(bnet, B, 'CPT', [0.85 0.15]); % 1=stable, 2=unstable
        bnet.CPD{W} = tabular_CPD(bnet, W, 'CPT', [2/7 5/7]); % 1=industrial, 2=household
        bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', [-3.9 -0.4], ...
            'cov', [0.00002 0.0001]);
        bnet.CPD{D} = gaussian_CPD(bnet, D, 'mean', [6.5 6.0], ...
            'cov', [0.03 0.04], ...
            'function', {sym('E'), sym('E')}) ;
        bnet.CPD{C} = gaussian_CPD(bnet, C, 'mean', [-2 -1], 'cov', [0.1 0.3]);
        bnet.CPD{L} = gaussian_CPD(bnet, L, 'mean', 3, 'cov', 0.25, 'function', {sym('-0.5*D')});
        bnet.CPD{Min} = gaussian_CPD(bnet, Min, 'mean', [0.5 -0.5],...
            'cov', [0.01 0.005]);
        bnet.CPD{Mout} = gaussian_CPD(bnet, Mout, 'mean', 0, ...
            'cov', 0.002, 'function', {sym('log(D) + Min')}); 
%         bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', [0 1], 'cov', [1 1],...
%             'weights',[1 .5]) ;
%         bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', [0 1], 'cov', [1 1],...
%             'function', {sym('W'), sym('0.5*W')}) ;
%         bnet.CPD{D} = gaussian_CPD(bnet, D, 'mean', [0 -1], 'cov', [5 1],...
%             'function', {sym('sqrt(W)*log(E)'), sym('sqrt(W)+E')}) ;
%         bnet.CPD{C} = gaussian_CPD(bnet, C, 'mean', [-2 -1], 'cov', [0.1 0.3]);
%         bnet.CPD{Min} = gaussian_CPD(bnet, Min, 'mean', 10, 'cov', 1,...
%             'function', {sym('exp(W^(1/3))')}) ;       
%         bnet.CPD{Mout} = gaussian_CPD(bnet, Mout, 'mean', 0, 'cov', 5,...
%             'function', {sym('0.5*D + Min')}) ;
%         bnet.CPD{L} = gaussian_CPD(bnet, L, 'mean', 0, 'cov', 5,...
%             'function', {sym('-5*D')}) ;   
    case 'hybrid_nonlinear_test'
        bnet.CPD{F} = tabular_CPD(bnet, F, 'CPT', [0.5 0.5]); % 1=intact, 2=defect                
        bnet.CPD{B} = tabular_CPD(bnet, B, 'CPT', [0.3 0.7]); % 1=stable, 2=unstable
        bnet.CPD{W} = tabular_CPD(bnet, W, 'CPT', [3/7 4/7]); % 1=industrial, 2=household
        bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', [-3 1], ...
            'cov', [1 1]);
        bnet.CPD{D} = gaussian_CPD(bnet, D, 'mean', [6 7], ...
            'cov', [0.1 0.1], ...
            'function', {sym('E'), sym('E')}) ;
        bnet.CPD{C} = gaussian_CPD(bnet, C, 'mean', [-2 -1], 'cov', [0.1 0.5]);
        bnet.CPD{L} = gaussian_CPD(bnet, L, 'mean', 3, 'cov', 0.25, 'function', {sym('-0.5*D')});
        bnet.CPD{Min} = gaussian_CPD(bnet, Min, 'mean', [0.5 -0.5],...
            'cov', [0.01 0.01]);
        bnet.CPD{Mout} = gaussian_CPD(bnet, Mout, 'mean', 0, ...
            'cov', 1, 'function', {sym('log(D) + Min')}, 'nonlinear', 1);         
end


        
