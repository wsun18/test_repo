function bnet = mk_subnet1_crossTest(CPD_type, p, arity)
% This is to create the subnet_2 containing two nodes with uniform
% prior, corresponding to Shou's node0, and node1
% -wsun, 9/7/12. 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'uniform'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    

N0 = 1;
N1 = 2 ;

n = 2;
dag = zeros(n);
dag(N0,N1) = 1;

dnodes = 1:n ;

ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'N0','N1'});

switch CPD_type
  case 'orig',
    bnet.CPD{N0} = tabular_CPD(bnet, N0, [0.5 0.5]);
    bnet.CPD{N1} = tabular_CPD(bnet, N1, [0.5 0.5 0.5 0.5]);
case 'uniform'
    bnet.CPD{N0} = tabular_CPD(bnet, N0, [0.5 0.5]);
    bnet.CPD{N1} = tabular_CPD(bnet, N1, [0.5 0.5 0.5 0.5]);
end

  
  
