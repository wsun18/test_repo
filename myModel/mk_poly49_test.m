function bnet = mk_poly49_test(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree.
% shown as following:
%
%

%              
%         L    
%          \   
%           \      
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

L = 1 ;
B = 2 ;
H = 3 ;
C = 4 ;
E = 5 ;
Y = 6 ;
W = 7 ;
Z = 8 ;

node_names = {'L', 'B', 'H', 'C', 'E', 'Y', 'W', 'Z'} ;

n = 8;
dag = zeros(n);

dag(L,B) = 1 ;
dag([H B],C) = 1 ;
dag(C,E) = 1 ;


dag([B Y],W) = 1;
dag(W,Z) = 1;

dnodes = [L B H C E] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig',         
        bnet.CPD{L} = tabular_CPD(bnet, L, [0.5 0.5]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.8 0.3 0.2 0.7]);
        bnet.CPD{H} = tabular_CPD(bnet, H, [0.5 0.5]);
        bnet.CPD{C} = tabular_CPD(bnet, C, [0.3 0.1 0.8 0.8 0.7 0.9 0.2 0.2]);
        bnet.CPD{E} = tabular_CPD(bnet, E, [0.1 0.9 0.9 0.1]);

        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 0, 'cov', 1) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [5 10], ...
            'cov', [1 2], 'weights', [1.0 2.0]) ;    
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
