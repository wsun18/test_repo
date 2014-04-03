function bnet = mk_abz_testnet6(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree.
% shown as following:
%
%             A       B 
%             |      / \
%            (X)    /   \
%              \   /     \
%               (W)       C
%                
%
% A, B, C, are discrete nodes.
% X, W, are continuous nodes.
%
% 

disp('Creating a test network -NO.6- consisting hybrid nodes ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

A = 1 ;
B = 2 ; C=3; 
X=4; W=5; 

node_names = {'A', 'B', 'C', 'X', 'W'} ;

n = 5;
dag = zeros(n);
dag(A,X) = 1;
dag(B,[C W]) = 1; 
dag(X,W) = 1; 


dnodes = [A B C] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);  
        bnet.CPD{C} = tabular_CPD(bnet, C, [.5 .3 .5 .7]); 
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', [-2 2], 'cov', [1 1]);
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [5 10], 'cov', [1 1], ...
            'weights', [1 1]);
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
