function bnet = mk_hybridTest_1d2c_connected_bnet(CPD_type, arity)

% mk_hybridTest_1d2c_bnet creates an example CLG of polytree, in which one
% continuous node W has one discrete parent A, and two continuous
% parents X, and Y, shown as below:
%

%             A  (X)<-(Y)
%              \  |   /
%               \ |  /
%                \| /
%                (W)
%                
%
% A is the discrete nodes.
% X, Y, W, are continuous nodes.
% W has one discrete parents and two continuous parents
% 

disp('Creating a CLG polytree network ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

A = 1 ;
Y = 2 ;
X = 3 ;
W = 4 ;


node_names = {'A', 'Y', 'X', 'W'} ;

n = 4;
dag = zeros(n);
dag(Y, X) = 1; 
dag([A X Y], W) = 1; 

dnodes = A ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);        
        
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 3, 'cov', 0.5) ;
        
        bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', -5, ...
            'cov', 1, 'weights', 0.5, 'function', {sym('0.5*Y')}) ;
        
        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [2 -1], ...
            'cov', [1 0.5], 'weights', [1.0 -1.5 2.0 1.0], ...
            'function', {sym('X - 1.5*Y'), sym('2*X+Y')}) ;    
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
