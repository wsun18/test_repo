function bnet = mk_abc_testnet7(CPD_type, arity)

% mk_abc_testnet7 creates a simple 3-node discrete network.
% shown as following:
%
%           A         B 
%            \       / 
%             \     /  
%              \   /  
%                C  
%
% A, B, C, are discrete nodes.
%
% 

disp('Creating a test network -NO.7- consisting of only 3 discrete nodes ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

A = 1 ;
B = 2 ; C=3; 

node_names = {'A', 'B', 'C'} ;

n = 3;
dag = zeros(n);
dag([A B], C) = 1;

dnodes = [A B C] ;
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);  
        bnet.CPD{C} = tabular_CPD(bnet, C, [.2 .9 .7 .5 .8 .1 .3 .5]); 
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
            
        for j=cnodes
            %bnet.CPD{j} = gaussian_CPD(bnet, j, 'cov', 1*eye(ns(j)));
            bnet.CPD{j} = gaussian_CPD(bnet, j)
        end
    otherwise,
        error('Error, wrong CPD type. Line 28') ;
        return ;
end
