function bnet = mk_priorTest2_bnet(CPD_type, p, arity)

%
%         MetaCancer
%           /   \
%          /     \
%         /       \
% SeriumCalcium   BrainTumor
%        \          /  
%         \        /     
%          \      /      
%           \    /         
%            Coma      
%             |
%             |
%             E
% 



if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'gauss', 'rndgauss', 
        'bool', 'cpt', 'nonlinear'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    

MetaCancer = 1;
SerumCalcium = 2;
BrainTumor = 3;
Coma = 4;
E = 5 ;


n = 5;
dag = zeros(n);
dag(MetaCancer, [SerumCalcium BrainTumor]) = 1;
dag([SerumCalcium BrainTumor], Coma) = 1;
dag(Coma, E) = 1 ;


ns = arity*ones(1,n);
if strcmp(CPD_type, 'gauss') || strcmp(CPD_type, 'rndgauss') ...
    || strcmp(CPD_type, 'nonlinear')
  dnodes = [];
else
  dnodes = 1:n;
end
bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'MetaCancer','SerumCalcium',...
    'BrainTumor','Coma', 'E'});

switch CPD_type
 case 'gauss',
     % when specifying function in CPD, all symbolic functions have to 
     % be in curly brace, not matter only one or more functions. 
     bnet.CPD{MetaCancer} = gaussian_CPD(bnet, MetaCancer, ...
         'mean', 30, 'cov', 1) ;
     bnet.CPD{SerumCalcium} = gaussian_CPD(bnet, SerumCalcium, ...
         'mean', 0, 'cov', 1, 'weights', -0.5, ... 
         'function', {sym('-.5*MetaCancer')} ) ;
     bnet.CPD{BrainTumor} = gaussian_CPD(bnet, BrainTumor, ...
         'mean', 5, 'cov', 1, 'weights', 2, ...
         'function', {sym('2*MetaCancer')} ) ;
     bnet.CPD{Coma} = gaussian_CPD(bnet, Coma, ...                  
         'mean', 0, 'cov', 1, 'weights', [-2 1], ...
         'function', {sym('-2*SerumCalcium + BrainTumor')} ) ; 
     bnet.CPD{E} = gaussian_CPD(bnet, E, ...
         'mean', 10, 'cov', 1, 'weights', 1.5, ...
         'function', {sym('1.5*Coma')});
end

  
  
