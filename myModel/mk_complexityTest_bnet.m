function bnet = mk_complexityTEst_bnet(CPD_type, arity)

% This is to create a polytree CLG with simple structure but is very
% difficulte for Junction tree algorithm to solve. 
% -wsun, 10 March 2011

% It has structure like the following:
%
%  A1    A2    A3    A4    A5    A6   A7 ....
%  |     |     |     |     |     |     |
%  |     |     |     |     |     |     |
%  |     |     |     |     |     |     |
%  C1 -- C2 -- C3 -- C4 -- C5 -- C6 -- C7 ...
%
% A1 to A_n are discrete nodes
% C1 to C_n are continuous nodes
%
% 

disp('Creating a CLG polytree network with state-space model structure...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

A1 = 1 ;
A2 = 2 ;
A3 = 3 ;
A4 = 4 ;
A5 = 5 ;
A6 = 6 ;
C1 = 7 ;
C2 = 8 ;
C3 = 9 ;
C4 = 10 ;
C5 = 11 ;
C6 = 12 ;

node_names = {'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6'} ;

n = 12;
dag = zeros(n) ;
dag(A1, C1) = 1 ;
dag([C1 A2], C2) = 1 ;
dag([C2 A3], C3) = 1 ;
dag([C3 A4], C4) = 1 ;
dag([C4 A5], C5) = 1 ;
dag([C5 A6], C6) = 1 ;

dnodes = [A1 A2 A3 A4 A5 A6] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 

% ======== parameters ============
nos = 2 ; % number of states
uft = ones(1,nos)/nos ; % uniform table
mu = ones(1,nos) ; % mean vector
for i=2:nos
    mu(1, i) = mu(1,i-1) + 1 ;
end 
var = ones(1,nos) ; % variance vector
wt = ones(1,nos) ; % weight vector

ns(dnodes) = nos ;
% ================================

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);


switch CPD_type
    case 'orig', 
        bnet.CPD{A1} = tabular_CPD(bnet, A1, uft) ;
        bnet.CPD{A2} = tabular_CPD(bnet, A2, uft) ;
        bnet.CPD{A3} = tabular_CPD(bnet, A3, uft) ;
        bnet.CPD{A4} = tabular_CPD(bnet, A4, uft) ;
        bnet.CPD{A5} = tabular_CPD(bnet, A5, uft) ;
        bnet.CPD{A6} = tabular_CPD(bnet, A6, uft) ;
            
        bnet.CPD{C1} = gaussian_CPD(bnet, C1, 'mean', mu, 'cov', var) ;
        bnet.CPD{C2} = gaussian_CPD(bnet, C2, 'mean', mu, 'cov', var, 'weights', wt) ;
        bnet.CPD{C3} = gaussian_CPD(bnet, C3, 'mean', mu, 'cov', var, 'weights', wt) ;
        bnet.CPD{C4} = gaussian_CPD(bnet, C4, 'mean', mu, 'cov', var, 'weights', wt) ;
        bnet.CPD{C5} = gaussian_CPD(bnet, C5, 'mean', mu, 'cov', var, 'weights', wt) ;
        bnet.CPD{C6} = gaussian_CPD(bnet, C6, 'mean', mu, 'cov', var, 'weights', wt) ;
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
