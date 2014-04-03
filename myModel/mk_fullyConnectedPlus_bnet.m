function bnet = mk_fullyConnectedPlus_bnet(N)
% Create a Bayes net with at least one big fully connected clique and
% several small cliques.
% The node with lower index has arcs to all ohter nodes indexed after it
% for the big fully connected clique.
% wsun, 12.15.2013



dag = zeros(N,N);

for i=1:N-1
    for j=i+1:N-1
        dag(i,j) = 1 ;
    end
end

plus = N; 

dag(N-1, plus) = 1 ;
dag(1, plus) = 1 ;
dag(unidrnd(N-3)+1,plus) = 1 ;

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
