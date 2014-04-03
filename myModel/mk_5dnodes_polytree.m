function bnet = mk_5dnodes_polytree(CPD_type, p, arity)
% This is to create a simple polytree network with 5 discrete nodes
% for testing asset updating algorithm exploiting conditional independence 
%
%            K
%            |
%    T       D
%     \     / \
%      \   /   \
%       \ /     \
%        E       F
%

% -wsun, 02/24/12. 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'gauss', 'rndgauss', 
        'bool', 'clg', 'nonlinear'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    

T=1 ;
K=2 ;
D = 3;
E = 4;
F = 5;

n = 5;
dag = zeros(n);
dag(T, E) = 1 ;
dag(K, D) = 1 ;
dag(D, [E F]) = 1;

dnodes = 1:5 ;

ns = arity*ones(1,n);
ns(dnodes) = 2 ;
ns(T)  = 3 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'T','K','D','E','F'});

switch CPD_type
  case 'orig',     
    bnet.CPD{T} = tabular_CPD(bnet, T, [0.5 0.2 .3]);
    bnet.CPD{K} = tabular_CPD(bnet, K, [0.5 0.5]);
    bnet.CPD{D} = tabular_CPD(bnet, D, [0.5 .1 0.5 .9]);    
    bnet.CPD{E} = tabular_CPD(bnet, E, [0.9 0.4 0.5 0.2 .7 .05 .1 .6 .5 .8 .3 .95]);    
    bnet.CPD{F} = tabular_CPD(bnet, F, [0.30 0.10 0.70 0.90]);
end

  
  
