function chain_bnet = mk_specialchain13()
% 10/06/13, wsun
% N1 -> N2 -> N3 -> N4 -> ... -> N9 -> A -> B -> C -> D

N = 13 ;

dag = zeros(N, N);
for i=1:N-1
    dag(i,i+1) = 1 ;
end

N = length(dag) ;
dnodes = 1:N ;
node_sizes = 1 + unidrnd(3,1,N-4) ;
% node_names = cell(1, N) ;
for i=1:9
%     node_names{i} = strcat('nod', int2str(i)) ;
    node_names{i} = strcat('N', int2str(i)) ;
end
node_names(end+1:end+4) = {'A','B','C','D'} ;
node_sizes(end+1:end+4) = 2 ;

chain_bnet = mk_bnet(dag, node_sizes, 'discrete', dnodes, ...
    'names', node_names);

% specify uniform  CPDs for all nodes
for k=1:N
    chain_bnet.CPD{k} = tabular_CPD(chain_bnet, k,'CPT','unif') ;
end

tw = mycheck_treewidth(chain_bnet) ;
