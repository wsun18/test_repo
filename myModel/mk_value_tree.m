function bnet = mk_value_tree(CPD_type, p, arity)


if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end


root = 1 ;
Q1 = 2 ;
Q2 = 3 ;
Q3 = 4 ;
Q4 = 5 ;


MetaCancer = 1;
SerumCalcium = 2;
BrainTumor = 3;
Coma = 4;
SHeadaches = 5;

n = 5;
dag = zeros(n);
dag(MetaCancer, [SerumCalcium BrainTumor]) = 1;
dag([SerumCalcium BrainTumor], Coma) = 1;
dag(BrainTumor, SHeadaches) = 1;

ns = arity*ones(1,n);
if strcmp(CPD_type, 'gauss') || strcmp(CPD_type, 'rndgauss') ...
    || strcmp(CPD_type, 'nonlinear')
  dnodes = [];
else
  dnodes = 1:n;
  ns(dnodes) = 2 ;
end
bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'MetaCancer','SerumCalcium',...
    'BrainTumor','Coma', 'SHeadaches'});

switch CPD_type
  case 'orig',     
    % absent is 1, present 2
    bnet.CPD{MetaCancer} = tabular_CPD(bnet, MetaCancer, [0.8 0.2]);
    % absent is 1, present 2
    bnet.CPD{SerumCalcium} = tabular_CPD(bnet, SerumCalcium, ...
        [0.8 0.2 0.2 0.8]);
    % absent is 1, present is 2
    bnet.CPD{BrainTumor} = tabular_CPD(bnet, BrainTumor, [0.95 0.8 0.05 0.2]);
    % absent is 1, present is 2
    bnet.CPD{Coma} = tabular_CPD(bnet, Coma, ...
        [0.95 0.2 0.2 0.2 0.05 0.8 0.8 0.8]);
    % absent is 1, present is 2
    bnet.CPD{SHeadaches} = tabular_CPD(bnet, SHeadaches, [0.4 0.2 0.6 0.8]) ;
 case 'bool',
  for i=1:n
    bnet.CPD{i} = boolean_CPD(bnet, i, 'rnd');
  end
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
         %'mean', 0, 'cov', 1, 'weights', [1 -2 1], ...   
         %'function', {sym('MetaCancer - 2*SerumCalcium + BrainTumor')} ) ;
     bnet.CPD{SHeadaches} = gaussian_CPD(bnet, SHeadaches, ...
         'mean', 0, 'cov', 0.5, 'weights', 1, ...
         'function', {sym('BrainTumor')} ) ;     
 case 'rndgauss',  
  for i=1:n
      %bnet.CPD{i} = gaussian_CPD(bnet, i, 'cov', 1*eye(ns(i)));
      bnet.CPD{i} = gaussian_CPD(bnet, i);
  end
 case 'nonlinear', 
     bnet.CPD{MetaCancer} = gaussian_CPD(bnet, MetaCancer, ...
         'mean', 10, 'cov', 1) ;
     bnet.CPD{SerumCalcium} = gaussian_CPD(bnet, SerumCalcium, ...
         'mean', 5, 'cov', 1, ...
         'function', {sym('log(MetaCancer)')}, 'nonlinear',1 ) ;
     bnet.CPD{BrainTumor} = gaussian_CPD(bnet, BrainTumor, ...
         'mean', 0, 'cov', 1, ...
         'function', {sym('exp(sqrt(MetaCancer))')}, 'nonlinear',1 ) ;
     bnet.CPD{Coma} = gaussian_CPD(bnet, Coma, ...                  
         'mean', 0, 'cov', 1, ...
         'function', {sym('SerumCalcium + sqrt(BrainTumor)')}, 'nonlinear',1 ) ;
     bnet.CPD{SHeadaches} = gaussian_CPD(bnet, SHeadaches, ...
         'mean', 0, 'cov', 0.5, ...
         'function', {sym('0.5*BrainTumor')} ) ;            
 case 'cpt',
  for i=1:n
    bnet.CPD{i} = tabular_CPD(bnet, i, p);
  end
end

  
  
