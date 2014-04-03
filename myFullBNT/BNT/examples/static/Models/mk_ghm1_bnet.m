function bnet = mk_ghm1_bnet(CPD_type, arity)
% MK_COMA_BNET Make the general hybrid model-1 bayes net.
% shown as following:
%
%             H         B
%           /   \      / \
%          /     \    /   \
%         /       \  /     \
%        F         K        |      (B, K: interface nodes)
%         \       /  \      |
%          \     /    \     T 
%           \   /      \   / \
%            \ /        \ /   \
%             G          R     S
%                         \   / \
%                          \ /   \
%                           M     Y
%
% B, H, F, K, G are discrete nodes.
% T, R, S, M, Y are continuous nodes.
%
% 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

H = 1 ;
B = 2 ;
T = 3 ;
F = 4 ;
K = 5 ;
R = 6 ;
S = 7 ;
G = 8 ;
M = 9 ;
Y = 10 ;

node_names = {'H', 'B', 'T', 'F', 'K', 'R', 'S', 'G', 'M', 'Y'} ;

n = 10;
dag = zeros(n);
dag([H B], K) = 1;
%dag(B, T) = 1 ;
dag(H, F) = 1;
dag([F K], G) = 1;
dag(K, R) = 1;
dag(T, [R S]) = 1;
dag([R S], M) = 1;
dag(S, Y) = 1;

dnodes = [H B F K G] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
  case 'orig',     
    % absent is 1, present 2
    bnet.CPD{H} = tabular_CPD(bnet, H, [0.8 0.2]);
    bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);
    % absent is 1, present 2
    bnet.CPD{F} = tabular_CPD(bnet, F, [0.8 0.2 0.2 0.8]);
    % absent is 1, present is 2
    bnet.CPD{K} = tabular_CPD(bnet, K, ...
        [0.4 0.8 0.1 0.5 0.6 0.2 0.9 0.5]);
    % absent is 1, present is 2
    bnet.CPD{G} = tabular_CPD(bnet, G, ...
        [0.85 0.6 0.9 0.75 0.15 0.4 0.1 0.25]);
    % absent is 1, present is 2
    %bnet.CPD{T} = gaussian_CPD(bnet, T, 'mean', [30 20], 'cov', [5 5]) ;
    bnet.CPD{T} = gaussian_CPD(bnet, T, 'mean', 30, 'cov', 5) ;
    bnet.CPD{R} = gaussian_CPD(bnet, R, 'mean', [-5 5], ...
        'cov', [5 5], 'weights', [1 1]) ;
    bnet.CPD{S} = gaussian_CPD(bnet, S, 'mean', 0, ...
        'cov', 2, 'weights', -2) ;
    bnet.CPD{M} = gaussian_CPD(bnet, M, 'mean', 5, ...
        'cov', 2, 'weights', [2 -1]) ;
    bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 0, ...
        'cov', 1, 'weights', 1) ;
 case 'rnd',  
  for i=dnodes
      bnet.CPD{i} = tabular_CPD(bnet, i);
  end
  for j=cnodes
      bnet.CPD{j} = gaussian_CPD(bnet, j);
  end
  end
end

  
  
