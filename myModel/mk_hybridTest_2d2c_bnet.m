function bnet = mk_hybridTest_2d2c_bnet(CPD_type, arity)

% mk_CLG_polytree_bnet creates an example CLG of polytree, in which one
% continuous node W has two discrete parents A, and B, and two continuous
% parents X, and Y, shown as below:
%

%           A  B (X)  (Y)
%            \ \  |   /
%             \ \ |  /
%              \ \| /
%                (W)
%                
%
% A, B, are discrete nodes.
% X, Y, W, are continuous nodes.
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
X = 3 ;
Y = 4 ;
W = 5 ;


node_names = {'A', 'B', 'X', 'Y', 'W'} ;

n = 5;
dag = zeros(n);
dag([A B X Y], W) = 1; 

dnodes = [A B] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.3 0.7]);     
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', -3, 'cov', 1) ;
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 3, 'cov', 0.5) ;
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [2 1 -2 0], ...
            'cov', [1 1 0.5 0.5], 'weights', [1.0 -0.5 1.0 1.0 -1.0 1.0 0.5 1.0], ...
            'function', {sym('X - 0.5*Y'),sym('X+Y'),sym('-X+Y'),sym('0.5*X+Y')}) ;    
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
