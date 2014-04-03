function bnet = mk_CLG_axyz_bnet(CPD_type)
% ToyPolyTree CLG
% Feb. 13, 2007
%
%  A     X 
%   \   /
%    \ /
%     Y
%     |
%     |
%     Z

if nargin == 0, CPD_type = 'orig'; end

A=1; X=2; Y=3; Z=4;

N = 4 ;
dag = zeros(N,N) ;
dag([1 2], 3) = 1 ;
dag(3, 4) = 1 ;

ns = [2 1 1 1] ;

dnodes = A ;
cnodes = mysetdiff(1:N, dnodes);
bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'A', 'X', 'Y', 'Z'}) ;
bnet.observed = dnodes ;

bnet.CPD{A} = tabular_CPD(bnet, A, 'CPT', [0.3 0.7]) ;  % 1=stable, 2=unstable
bnet.CPD{X} = gaussian_CPD(bnet, X, 'mean', 0, 'cov', 1)  ;
bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', [0 5], ...
    'cov', [0.5 0.5], 'weights', [1 1], ...
    'function', {sym('X'), sym('X')}) ;
bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', 0, 'cov', 0.5, 'weights', -1) ;



