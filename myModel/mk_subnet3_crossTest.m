function bnet = mk_subnet3_crossTest(CPD_type, p, arity)
% This is to create the subnet_3 containing four nodes with uniform
% prior, corresponding to Shou's node6, node 5, node8, and node7
% -wsun, 9/7/12. 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'uniform'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    

N6 = 1 ;
N5 = 2 ;
N8 = 3 ;
N7 = 4 ;

n = 4;
dag = zeros(n);
dag(N6,[N5 N8]) = 1 ;
dag([N5 N8],N7) = 1 ;

dnodes = 1:n ;

ns(dnodes) = 2 ;
ns(N5) = 3 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'N6','N5','N8','N7'});

switch CPD_type
  case 'orig',
    bnet.CPD{N6} = tabular_CPD(bnet, N6, [0.5 0.5]);
    bnet.CPD{N5} = tabular_CPD(bnet, N5, [0.33333 0.33333 0.33333 0.33333 0.33334 0.33334]);
    bnet.CPD{N8} = tabular_CPD(bnet, N8, [0.5 0.5 0.5 0.5]);
    bnet.CPD{N7} = tabular_CPD(bnet, N7, [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5]);
case 'uniform'
    bnet.CPD{N6} = tabular_CPD(bnet, N6, [0.5 0.5]);
    bnet.CPD{N5} = tabular_CPD(bnet, N5, [0.33333 0.33333 0.33333 0.33333 0.33334 0.33334]);
    bnet.CPD{N8} = tabular_CPD(bnet, N8, [0.5 0.5 0.5 0.5]);
    bnet.CPD{N7} = tabular_CPD(bnet, N7, [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5]);
end

  
  
