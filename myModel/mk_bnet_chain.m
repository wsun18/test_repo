function chain_bnet = mk_bnet_chain(N,string)
% 09/03/2013, create a N-node BN consisting of a chain, similar to the
% following:
% N1 -> N2 -> N3 -> N4 -> ... -> NN


if nargin < 2, string='binary'; end


dag = zeros(N,N);
for i=1:N-1
    dag(i,i+1) = 1 ;
end

dnodes = 1:N ;

switch string
    case 'binary'
        node_sizes = 2 * ones(1,N) ;
    case 'multi'
        node_sizes = 1 + unidrnd(3,1,N) ;
    otherwise
        error('you must specify the type of variable states') ;         
end
node_names = cell(1, N) ;
for i=1:N
%     node_names{i} = strcat('nod', int2str(i)) ;
    node_names{i} = strcat('N', int2str(i)) ;
end

chain_bnet = mk_bnet(dag, node_sizes, 'discrete', dnodes, ...
    'names', node_names);

% specify uniform  CPDs for all nodes
for k=1:N
    chain_bnet.CPD{k} = tabular_CPD(chain_bnet, k,'CPT','unif') ;
end

tw = mycheck_treewidth(chain_bnet) ;
