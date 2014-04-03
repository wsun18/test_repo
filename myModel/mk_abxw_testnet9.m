function bnet = mk_abxw_testnet9(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree.
% shown as following:
%
%             A       B 
%             |      / 
%            (X)    /  
%              \   /   
%               (W)    
%
% A, B, are discrete nodes.
% X, W, are continuous nodes.
%
% 

disp('Creating a test network -NO.5- consisting hybrid nodes ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear', ...
        'disc', 'gaussian'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

A = 1 ;
B = 2 ; 
X=3; W=4; 

node_names = {'A', 'B', 'X', 'W'} ;

n = 4;
dag = zeros(n);
dag(A,X) = 1;
dag([B X],W) = 1; 

switch CPD_type
    case 'orig'
        dnodes = [A B] ;        
    case 'gaussian'
        dnodes = [];
    case 'disc'
        dnodes = [A B X W];
end

cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);           
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', [1 3], 'cov', [1 1]);
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [-1 1], 'cov', [1 1], ...
            'weights', [1 1]);
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
            
        for j=cnodes
            %bnet.CPD{j} = gaussian_CPD(bnet, j, 'cov', 1*eye(ns(j)));
            bnet.CPD{j} = gaussian_CPD(bnet, j)
        end
    case 'gaussian'
        bnet.CPD{A} = gaussian_CPD(bnet, A, 'mean', 10, 'cov', 2) ;
        bnet.CPD{B} = gaussian_CPD(bnet, B, 'mean', 2, 'cov', 1);           
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', 0, 'cov', 1, 'weights', 1);
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', 0, 'cov', 1, 'weights', [1 1]);        
    case 'disc'
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);
        bnet.CPD{X} = tabular_CPD(bnet, X, [0.8 0.1 .2 .9]);
        bnet.CPD{W} = tabular_CPD(bnet, W, [0.5 0.5 .2 .4 .5 .5 .8 .6]);
    otherwise,
        error('Error, wrong CPD type. Line 28') ;
        return ;
end
