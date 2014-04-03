function bnet = mk_CLG_polytree_oneInterface(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree.
% shown as following:
%
%          (P)       (U)
%            \       /
%             \     /
%              \   /
%         A     (X)
%          \      \
%           \      \
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
% P U, X, Y, W, and Z are continuous nodes.
%
% 

disp('Creating a CLG polytree network ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

P=1; U=2; X=3; 
A=4; B=5; C=6; 
Y=7; W=8; Z=9; 

node_names = {'P', 'U', 'X', 'A', 'B', 'C', 'Y', 'W', 'Z'} ;

n = 9;
dag = zeros(n);
dag([P U], X) = 1;
dag(X,Y) = 1;
dag(Y,W) = 1;
dag(A, B) = 1;
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
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.3 0.5 0.7 0.5]);
        bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.3 0.5 0.7]);
        bnet.CPD{P} = gaussian_CPD(bnet, P, 'mean', 10, 'cov', 1) ;
        bnet.CPD{U} = gaussian_CPD(bnet, U, 'mean', 30, 'cov', 2) ;
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', [-5 5], ...
            'cov', [1 1], 'weights', [1 1]) ;
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 0, 'cov', 1, 'weights', -2) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [5 20], ...
            'cov', [1 2], 'weights', [1 2]) ;    
        bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', 0, ...
            'cov', 1, 'weights', 0.5) ;
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
            
        for j=cnodes
            %bnet.CPD{j} = gaussian_CPD(bnet, j, 'cov', 1*eye(ns(j)));
            bnet.CPD{j} = gaussian_CPD(bnet, j) ;
        end
    otherwise,
        error('Error, wrong CPD type. Line 28') ;
        return ;
end
