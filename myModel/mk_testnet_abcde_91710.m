function bnet = mk_testnet_abcde_91710(CPD_type, arity)

%
%             A      B 
%              \     / 
%               \   /  
%                \ /
%                 C 
%                / \ 
%               /   \ 
%              /     \
%             D       E
% 

disp('Creating a test network consisting of 5 pure discrete nodes ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

A = 1 ;
B = 2 ; C=3; 
D=4; E=5;

node_names = {'A', 'B', 'C', 'D', 'E'} ;

n = 5;
dag = zeros(n);
dag([A B], C) = 1;
dag(C,[D E]) = 1; 

dnodes = [A B C D E] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5]);  
        bnet.CPD{C} = tabular_CPD(bnet, C, [.2 .9 .7 .5 .8 .1 .3 .5])
        bnet.CPD{D} = tabular_CPD(bnet, D, [.3 .8 .7 .2]) ;
        bnet.CPD{E} = tabular_CPD(bnet, E, [.5 .1 .5 .9]);        
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
