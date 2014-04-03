function bnet = mk_DEF2_dummy_bnet(CPD_type, p, arity)
% This is to create a very simple pure discrete network to show the first
% MPE principle - individually picking the most likely value do not necessrily
% provide the true MPE: 
% -by wsun on 10/30/10
%
% DEF is a pure discrete BN with only 3 nodes:
%
%            D
%           / \
%          /   \
%         /     \
%        E       F
%
% BNET = MK_MPETEST_DEF_BNET('orig') is to create the net with the original
% parameters cooked to show the point.

% -wsun, 11/08/10. I modified the model to accomodate CLG by allowing F to
% be a Gaussian node. 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'gauss', 'rndgauss', 
        'bool', 'clg', 'nonlinear'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    

D = 1;
E = 2;
F = 3;
dummy1 = 4 ;
dummy2 = 5 ;

n = 5;
dag = zeros(n);
dag(D, [E F]) = 1;
dag(E, dummy1) = 1 ;
dag([D F], dummy2) = 1 ;

if strcmp(CPD_type, 'gauss') || strcmp(CPD_type, 'rndgauss') || strcmp(CPD_type, 'nonlinear')
    dnodes = [];
    else if strcmp(CPD_type, 'clg')
            dnodes = [1 2];
        else if strcmp(CPD_type, 'orig')
                dnodes = 1:n;
            end
        end
end

ns = arity*ones(1,n);
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'D','E','F','dummy'});

%%%%%%%%%%
ch = 0.8 ;

pl(1) = ch/.65 ;
pl(2) = (1-ch)/.35 ;
pl = pl/sum(pl) ;
pdummy1 = [pl 1-pl] ;

pdummy2 = [0.25182 0.25182 0.33898 0.15738] ;

%%%%%%%%%%%

switch CPD_type
  case 'orig',     
    % present is 1, absent is 2
    bnet.CPD{D} = tabular_CPD(bnet, D, [0.5 0.5]);
    % increased is 1, not increased is 2
    bnet.CPD{E} = tabular_CPD(bnet, E, [0.9 0.4 0.1 0.6]);
    % present is 1, absent is 2
    bnet.CPD{F} = tabular_CPD(bnet, F, [0.30 0.10 0.70 0.90]);
    bnet.CPD{dummy1} = tabular_CPD(bnet, dummy1, pdummy1);
    bnet.CPD{dummy2} = tabular_CPD(bnet, dummy2, [pdummy2 1-pdummy2]);
%  case 'bool',
%   for i=1:n
%     bnet.CPD{i} = boolean_CPD(bnet, i, 'rnd');
%   end
%  case 'gauss',
%      % when specifying function in CPD, all symbolic functions have to 
%      % be in curly brace, not matter only one or more functions. 
%      bnet.CPD{MetaCancer} = gaussian_CPD(bnet, MetaCancer, ...
%          'mean', 30, 'cov', 1) ;
%      bnet.CPD{SerumCalcium} = gaussian_CPD(bnet, SerumCalcium, ...
%          'mean', 0, 'cov', 1, 'weights', -0.5, ... 
%          'function', sym('-.5*MetaCancer') ) ;
%      bnet.CPD{BrainTumor} = gaussian_CPD(bnet, BrainTumor, ...
%          'mean', 5, 'cov', 1, 'weights', 2, ...
%          'function', sym('2*MetaCancer') ) ;
%      bnet.CPD{Coma} = gaussian_CPD(bnet, Coma, ...                  
%          'mean', 0, 'cov', 1, 'weights', [-2 1], ...
%          'function', sym('-2*SerumCalcium + BrainTumor') ) ;
%          %'mean', 0, 'cov', 1, 'weights', [1 -2 1], ...   
%          %'function', sym('MetaCancer - 2*SerumCalcium + BrainTumor') ) ;
%      bnet.CPD{SHeadaches} = gaussian_CPD(bnet, SHeadaches, ...
%          'mean', 0, 'cov', 0.5, 'weights', 1, ...
%          'function', sym('BrainTumor') ) ;     
%  case 'rndgauss',  
%   for i=1:n
%       %bnet.CPD{i} = gaussian_CPD(bnet, i, 'cov', 1*eye(ns(i)));
%       bnet.CPD{i} = gaussian_CPD(bnet, i);
%   end
%  case 'nonlinear', 
%      bnet.CPD{MetaCancer} = gaussian_CPD(bnet, MetaCancer, ...
%          'mean', 10, 'cov', 1) ;
%      bnet.CPD{SerumCalcium} = gaussian_CPD(bnet, SerumCalcium, ...
%          'mean', 5, 'cov', 1, ...
%          'function', sym('log(MetaCancer)') ) ;
%      bnet.CPD{BrainTumor} = gaussian_CPD(bnet, BrainTumor, ...
%          'mean', 0, 'cov', 1, ...
%          'function', sym('exp(sqrt(MetaCancer))') ) ;
%      bnet.CPD{Coma} = gaussian_CPD(bnet, Coma, ...                  
%          'mean', 0, 'cov', 1, ...
%          'function', sym('SerumCalcium + sqrt(BrainTumor)') ) ;
%      bnet.CPD{SHeadaches} = gaussian_CPD(bnet, SHeadaches, ...
%          'mean', 0, 'cov', 0.5, ...
%          'function', sym('0.5*BrainTumor') ) ;            
 case 'clg', %-wsun, 11/08/10. creating a CLG model by allowing F to be a Gaussian
     % present is 1, absent is 2
     bnet.CPD{D} = tabular_CPD(bnet, D, [0.5 0.5]);
     % increased is 1, not increased is 2
     bnet.CPD{E} = tabular_CPD(bnet, E, [0.6 0.4 0.4 0.6]);
     % let F to be a Gaussian
     bnet.CPD{F} = gaussian_CPD(bnet, F, 'mean', [1 3], 'cov', [0.5 2]) ;
end

  
  
