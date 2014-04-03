function bnet = mk_hybridTest_3pdp_bnet(CPD_type, arity)

% mk_hybridTest_3pdp_bnet creates an example CLG of polytree, consisting of
% one continuous node with 3 pure discrete parents, shown as below:
%
%             A    B    C  
%              \   |   /
%               \  |  /
%                \ | /
%                 (Z)
%                
%
% A, B, and C are discrete nodes.
% Z is continuous nodes.
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
Z = 4 ;


node_names = {'A', 'B', 'C', 'Z'} ;

n = 4;
dag = zeros(n);
dag([A B C], Z) = 1; 

dnodes = [A B C] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig', 
        bnet.CPD{A} = tabular_CPD(bnet, A, [0.8 0.2]);
        bnet.CPD{B} = tabular_CPD(bnet, B, [0.3 0.7]);
        bnet.CPD{C} = tabular_CPD(bnet, C, [0.6 0.4]);
        bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', [3 -1 0 1 2 -2 0 1], ...
            'cov', [1 1 1 0.5 1 1 1 0.5]) ;        
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
