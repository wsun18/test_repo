function bnet = mk_puredisc_polytree_bnet(CPD_type, arity)

% mk_disc_polytree_bnet: create an example network consisting of purely 
% discrete varaibles with the sturture as below
%
%           A         U
%            \       /
%             \     /
%              \   /
%                X
%                 \
%                  \
%            B      Y
%           / \    /
%          /   \  /
%         C      W
%                |
%                |
%                Z
%
%
%
% 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd'})
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

node_names = {'A', 'B', 'C', 'U', 'X', 'Y', 'W', 'Z'} ;

n = 8;
dag = zeros(n);
dag([A U], X) = 1;
dag(X,Y) = 1;
dag(Y,W) = 1;
dag(B, [C W]) = 1 ;
dag(W,Z) = 1;

dnodes = 1:n;
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);
        bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.3 0.5 0.7]);
        %{
        bnet.CPD{U} = gaussian_CPD(bnet, U, 'mean', 30, 'cov', 2) ;
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', [-5 5], ...
            'cov', [1 1], 'weights', [1 1]) ;
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 0, 'cov', 1, 'weights', -2) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [5 20], ...
            'cov', [1 2], 'weights', [1 2]) ;    
        bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', 0, ...
            'cov', 1, 'weights', 0.5) ;
        %}
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end      
    otherwise,
        error('Error, wrong CPD type. Line 28') ;
        return ;
end
