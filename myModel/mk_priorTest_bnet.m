function bnet = mk_priorTest_bnet(CPD_type, p, arity)


% SeriumCalcium   BrainTumor
%        \          /  \
%         \        /    \
%          \      /      \
%           \    /        \
%            Coma      SevereHeadaches
%
% 
% BNET = MK_COMA_BNET('cpt', p) uses random parameters drawn from a Dirichlet(p,p,...)
% distribution. If p << 1, this is nearly deterministic; if p >> 1, this is nearly uniform.
% 
% BNET = MK_COMA_BNET('bool') makes each CPT a random boolean function.
%
% BNET = MK_COMA_BNET('gauss') makes each CPT a random linear Gaussian distribution.
%
% BNET = MK_COMA_BNET('orig') is the same as MK_ASIA_BNET.
%
% BNET = MK_COMA_BNET('cpt', p, arity) can specify non-binary nodes.


if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'gauss', 'rndgauss', 
        'bool', 'cpt', 'nonlinear'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    


SerumCalcium = 1;
BrainTumor = 2;
Coma = 3;
SHeadaches = 4;

n = 4;
dag = zeros(n);
dag([SerumCalcium BrainTumor], Coma) = 1;
dag(BrainTumor, SHeadaches) = 1;

ns = arity*ones(1,n);
if strcmp(CPD_type, 'gauss') || strcmp(CPD_type, 'rndgauss') ...
    || strcmp(CPD_type, 'nonlinear')
  dnodes = [];
else
  dnodes = 1:n;
end
bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'SerumCalcium',...
    'BrainTumor','Coma', 'SHeadaches'});

switch CPD_type
    case 'gauss'
         % when specifying function in CPD, all symbolic functions have to 
         % be in curly brace, not matter only one or more functions. 
         bnet.CPD{SerumCalcium} = gaussian_CPD(bnet, SerumCalcium, ...
             'mean', 0, 'cov', 1) ;
         bnet.CPD{BrainTumor} = gaussian_CPD(bnet, BrainTumor, ...
             'mean', 5, 'cov', 1) ;
         bnet.CPD{Coma} = gaussian_CPD(bnet, Coma, ...                  
             'mean', 0, 'cov', 1, 'weights', [-2 1], ...
             'function', {sym('-2*SerumCalcium + BrainTumor')} ) ;
         bnet.CPD{SHeadaches} = gaussian_CPD(bnet, SHeadaches, ...
             'mean', 0, 'cov', 0.5, 'weights', 1, ...
             'function', {sym('BrainTumor')} ) ;   
    otherwise
        disp('wrong')
end

  
  
