function bnet = mk_poly12CLG_bnet(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree.
% shown as following:
%
%
%           V
%           |
%           | 
%           |
%           A        (U)
%            \       /
%             \     /
%              \   /
%         L     (X)
%          \      \
%           \      \
%      H     B     (Y)
%       \   / \    /
%        \ /   \  /
%         C     (W)
%         |      |
%         |      |
%         E     (Z)
%
%
% A, B, and C are discrete nodes.
% U, X, Y, W, and Z are continuous nodes.
%
% 

disp('Creating a CLG polytree network ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

V = 1 ;
A = 2 ;
L = 3 ;
B = 4 ;
H = 5 ;
C = 6 ;
E = 7 ;
U = 8 ;
X = 9 ;
Y = 10 ;
W = 11 ;
Z = 12 ;

node_names = {'V', 'A', 'L', 'B', 'H', 'C', 'E', 'U', 'X', 'Y', 'W', 'Z'} ;

n = 12;
dag = zeros(n);
dag(V,A) = 1 ;
dag(L,B) = 1 ;
dag([H B],C) = 1 ;
dag(C,E) = 1 ;
dag([A U], X) = 1;
dag(X,Y) = 1;
dag([B Y],W) = 1;
dag(W,Z) = 1;

dnodes = [V A L B H C E] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{V} = tabular_CPD(bnet, V, [0.8 0.2]);
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.5 0.4 0.5 0.6]);
        bnet.CPD{L} = tabular_CPD(bnet, L, [0.5 0.5]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.6 0.3 0.4 0.7]);
        bnet.CPD{H} = tabular_CPD(bnet, H, [0.3 0.7]);
        bnet.CPD{C} = tabular_CPD(bnet, C, [0.3 0.5 0.4 0.6 0.7 0.5 0.6 0.4]);
        bnet.CPD{E} = tabular_CPD(bnet, E, [0.5 0.9 0.5 0.1]);
        bnet.CPD{U} = gaussian_CPD(bnet, U, 'mean', 30, 'cov', 2) ;
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', [-5 5], ...
            'cov', [1 1], 'weights', [1 1]) ;
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 0, 'cov', 1, 'weights', -2.0) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [5 -1], ...
            'cov', [1 2], 'weights', [1.0 1.0]) ;    
        bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', 0, ...
            'cov', 1, 'weights', 0.5) ;
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
            
        for j=cnodes
            bnet.CPD{j} = gaussian_CPD(bnet, j); %, 'cov', 1*eye(ns(j)));
        end
    otherwise,
        error('Error, wrong CPD type. Line 28') ;
        return ;
end
