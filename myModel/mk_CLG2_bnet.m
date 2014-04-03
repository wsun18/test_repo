function bnet = mk_CLG2_bnet(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree.
% shown as following:
%
%           A        (U)
%            \       /
%             \     /
%              \   /
%               (X)   (T)
%                 \   /
%                  \ /
%            B     (Y)
%           / \    /
%          /   \  /
%         C     (W)
%                |
%                |
%               (Z)
%
%
% A, B, and C are discrete nodes.
% U, X, T, Y, W, and Z are continuous nodes.
%
% 

disp('Creating a CLG polytree network ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

A = 1 ;
B = 2 ;
C = 3 ;
U = 4 ;
X = 5 ;
T = 6 ;
Y = 7 ;
W = 8 ;
Z = 9 ;

node_names = {'A', 'B', 'C', 'U', 'X', 'T', 'Y', 'W', 'Z'} ;

n = 9;
dag = zeros(n);
dag([A U], X) = 1;
dag([X T],Y) = 1;
dag(Y,W) = 1;
dag(B, [C W]) = 1 ;
dag(W,Z) = 1;

dnodes = [A B C] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);
        bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.3 0.5 0.7]);
        bnet.CPD{U} = gaussian_CPD(bnet, U, 'mean', 30, 'cov', 2) ;
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', [-5 5], ...
            'cov', [1 1], 'weights', [1 1]) ;
        bnet.CPD{T} = gaussian_CPD(bnet, T, 'mean', 10, 'cov', 1) ;
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 0, 'cov', 1, 'weights', [-2.0 1.0]) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [5 20], ...
            'cov', [1 2], 'weights', [1.0 2.0]) ;    
        bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', 0, ...
            'cov', 1, 'weights', 0.5) ;
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
            
        for j=cnodes
            bnet.CPD{j} = gaussian_CPD(bnet, j, 'cov', 1*eye(ns(j)));
        end
    otherwise,
        error('Error, wrong CPD type. Line 28') ;
        return ;
end
