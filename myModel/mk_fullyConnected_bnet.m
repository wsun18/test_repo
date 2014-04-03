function bnet = mk_fullyConnected_bnet(N)
% 12/10/13, wsun, create fully connected Bayes net
% The node with lower index has arcs to all ohter nodes indexed after it. 




dag = zeros(N, N);

for i=1:N-1
    for j=i+1:N
        dag(i,j) = 1 ;
    end
end

dnodes = 1:N ;
node_sizes = 2*ones(1,N) ;

node_names = cell(1,N);
for i = 1:N
    node_names{i} = strcat('Q', int2str(i));
end


bnet = mk_bnet(dag, node_sizes, 'discrete', dnodes, ...
    'names', node_names);

% BGobj = biograph(dag,node_names);
% view(BGobj);

% specify uniform  CPDs for all nodes
for k=1:N
    bnet.CPD{k} = tabular_CPD(bnet, k,'CPT','unif') ;
end

tw = mycheck_treewidth(bnet) ;
