function bnet = mk_subnet2_crossTest(CPD_type, p, arity)
% This is to create the subnet_2 containing three nodes with uniform
% prior, corresponding to Shou's node2, and node3, node4
% -wsun, 9/7/12. 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'uniform'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    

N2 = 1 ;
N4 = 2 ;
N3 = 3 ;

n = 3;
dag = zeros(n);
dag([N2 N4],N3) = 1 ;

dnodes = 1:n ;

ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'N2','N4','N3'});

switch CPD_type
  case 'orig',
    bnet.CPD{N2} = tabular_CPD(bnet, N2, [0.5 0.5]);
    bnet.CPD{N4} = tabular_CPD(bnet, N4, [0.5 0.5]);
    bnet.CPD{N3} = tabular_CPD(bnet, N3, [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5]);
case 'uniform'
    bnet.CPD{N2} = tabular_CPD(bnet, N2, [0.5 0.5]);
    bnet.CPD{N4} = tabular_CPD(bnet, N4, [0.5 0.5]);
    bnet.CPD{N3} = tabular_CPD(bnet, N3, [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5]);
end

  
  
