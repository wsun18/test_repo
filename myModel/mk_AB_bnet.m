function bnet = mk_AB_bnet()


A=1; B=2; 
n = 2 ;
dag = zeros(n);
dag(A, B) = 1;

arity = 2 ;
ns = arity*ones(1,n);
dnodes = 1:n;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'A','B'});

for k=1:n
    bnet.CPD{k} = tabular_CPD(bnet, k,'CPT','unif') ;
end

