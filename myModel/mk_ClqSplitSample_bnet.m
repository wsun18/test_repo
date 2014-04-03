function bnet = mk_ClqSplitSample_bnet1()


A=1; B=2; C=3; D=4; E=5; 

n = 5;
dag = zeros(n);
dag(A, [B C]) = 1;
dag(B, D) = 1;
dag([C D], E) = 1;

ns = arity*ones(1,n);
if strcmp(CPD_type, 'gauss')
  dnodes = [];
else
  dnodes = 1:n;
end
bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'A','B',...
    'C','D', 'E'});

bnet.CPD{A} = tabular_CPD(bnet, A, [0.5 0.5]);
bnet.CPD{B} = tabular_CPD(bnet, B, [0.5 0.5 .5 .5]);
bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5 .5 .5]);
bnet.CPD{D} = tabular_CPD(bnet, D, [0.5 0.5 .5 .5]);
bnet.CPD{E} = tabular_CPD(bnet, E, [0.5 0.5 .5 .5]);

