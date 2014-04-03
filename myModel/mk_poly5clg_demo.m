function bnet = mk_poly5clg_demo(CPD_type, arity)

% mk_poly5clg_demo creates an example CLG of polytree.
% shown as following:
%
%            T     (Y)
%           / \    /
%          /   \  /
%         C     (W)
%                |
%                |
%               (Z)
%
%
% T and C are discrete nodes.
% Y, W, and Z are continuous nodes.
% For illustrating message computations in DMP algorithm.
% 

disp('Creating a CLG polytree network ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

T = 1 ;
C = 2 ;
Y = 3 ;
W = 4 ;
Z = 5 ;

node_names = {'T', 'C', 'Y', 'W', 'Z'} ;

n = 5;
dag = zeros(n);
dag(T, C) = 1;
dag([T Y],W) = 1;
dag(W,Z) = 1;

dnodes = [T C] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig',         
        bnet.CPD{T} = tabular_CPD(bnet, T, [0.5 0.5]);
        bnet.CPD{C} = tabular_CPD(bnet, C, [0.8 0.3 0.2 0.7]);
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 10, 'cov', 1) ;        
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [-1 1], ...
            'cov', [1 1], 'weights', [1.0 1.0]) ;    
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
