function bnet = mk1_ClqSplitSample_bnet()


A=1; B=2; C=3; D=4; E=5; 

n = 5;
dag = zeros(n);
dag(A, [B C]) = 1;
dag(B, D) = 1;
dag([C D], E) = 1;

arity = 2 ;
ns = arity*ones(1,n);
dnodes = 1:n;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'A','B',...
    'C','D', 'E'});

for k=1:n
    bnet.CPD{k} = tabular_CPD(bnet, k,'CPT','unif') ;
end


% bnet.CPD{A} = tabular_CPD(bnet, A, [0.5 0.5]);
% bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5 .5 .5]);
% bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5 .5 .5]);
% bnet.CPD{D} = tabular_CPD(bnet, D, [0.5 0.5 .5 .5]);
% bnet.CPD{E} = tabular_CPD(bnet, E, [0.5 0.5 .5 .5 .5 .5 .5 .5]);

