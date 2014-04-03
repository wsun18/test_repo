function bnet = mk_hybridTest_polyCLG_bnet(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree.
% shown as following:
%
%                (U)
%                 |
%                 |
%                 |
%           A  B (X)  (Y)
%          /|\ \  |   /
%         / | \ \ |  /
%        /  |  \ \| /
%       C  (Z)   (W)
%                 |
%                 |
%                (E)
%                
%
% A, B, and C are discrete nodes.
% U, X, Y, W, Z and E are continuous nodes.
% W has two discrete parents and two continuous parents
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
Y = 6 ;
W = 7 ;
Z = 8 ;
E = 9 ;

node_names = {'A', 'B', 'C', 'U', 'X', 'Y', 'W', 'Z', 'E'} ;

n = 9;
dag = zeros(n);
dag(A,[C Z]) = 1; 
dag(U,X) = 1; 
dag([A B X Y], W) = 1;
dag(W,E) = 1;

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
        bnet.CPD{U} = gaussian_CPD(bnet, U, 'mean', 30, 'cov', 1) ;
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', -5, ...
            'cov', 1, 'weights', 0.5, 'function', {sym('0.5*U')}) ;
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 3, 'cov', 1) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [5 20 10 -5], ...
            'cov', [1 2 1 0.5], 'weights', [1.0 -0.5 1.0 1.0 -1.0 1.0 0.5 1.0], ...
            'function', {sym('X - 0.5*Y'),sym('X+Y'),sym('-X+Y'),sym('0.5*X+Y')}) ;    
        bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', [3 -1], 'cov', [1 1]) ;
        bnet.CPD{E} = gaussian_CPD(bnet, E, 'mean', 0, 'cov', 1, 'weights',0.5, ...
            'function', {sym('0.5*W')} ) ;
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
            
        for j=cnodes
            bnet.CPD{j} = gaussian_CPD(bnet, j, 'cov', 1*eye(ns(j)));
        end
    otherwise,
        error('Error, wrong CPD type!') ;
        return ;
end
