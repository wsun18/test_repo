function bnet = mk_ABC_bnet()

% A   B
%  \ /
%   C

A=1; B=2; C=3; 

n = 3;
dag = zeros(n);
dag([A B], C) = 1;

arity = 2 ;
ns = arity*ones(1,n);
ns(A) = 3 ;
dnodes = 1:n;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'A','B','C'});

for k=1:n
    bnet.CPD{k} = tabular_CPD(bnet, k,'CPT','unif') ;
end


