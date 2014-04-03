function bnet = mk_dynamicAssetCluster_TestModel()
% 10/29/13, wsun, test model for dynamic asset cluster model
%         A 
%         | \
%     T - B  \
%     |   |   \
%     X   C -> W

N = 6 ;
A = 1 ;
B = 2 ;
C = 3 ;
W = 4 ;
T = 5 ;
X = 6 ;

dag = zeros(N, N);
dag(A,B) = 1 ;
dag(B,[T C]) = 1 ;
dag(T,X) = 1 ;
dag([A C],W) = 1 ;

dnodes = 1:N ;
node_sizes = 2*ones(1,N) ;

node_names = {'A','B','C','W','T','X'} ;


bnet = mk_bnet(dag, node_sizes, 'discrete', dnodes, ...
    'names', node_names);

% specify uniform  CPDs for all nodes
for k=1:N
    bnet.CPD{k} = tabular_CPD(bnet, k,'CPT','unif') ;
end

tw = mycheck_treewidth(bnet) ;
