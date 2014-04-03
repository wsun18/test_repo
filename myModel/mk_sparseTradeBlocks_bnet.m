function bnet = mk_sparseTradeBlocks_bnet(nos)
% Create a Bayes net with 5-cliques: the biggest clique has 5 questions;
% two other cliques have 3 questions in each clique; the remaining two
% cliques have 2 questions in each clique.
% -wsun, 3.15.2014

%   A  B     C  D     F
%    \  \   /  / \   /
%     \  \ /  /   \ /
%      \  |  /     | 
%       \ | /      | 
%         E        G   S
%         |         \ /
%         K          H
%         |
%         W

% 'nos' is number of states for each variable.

A=1; B=2; C=3; D=4; E=5; 
F=6; G=7; 
K=8; W=9; 
S=10; H=11;

N = 11 ; % number of nodes.

dag = zeros(N,N);

dag([A,B,C,D],E) = 1 ;
dag([D,F],G) = 1 ;
dag([G,S],H) = 1 ;
dag(E,K) = 1 ;
dag(K,W) = 1 ;

dnodes = 1:N ;
node_sizes = nos*ones(1,N) ;

node_names = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'K', 'W', 'S', 'H'} ;

bnet = mk_bnet(dag, node_sizes, 'discrete', dnodes, ...
    'names', node_names);

% BGobj = biograph(dag,node_names);
% view(BGobj);

% specify uniform  CPDs for all nodes
for k=1:N
    bnet.CPD{k} = tabular_CPD(bnet, k,'CPT','unif') ;
end

tw = mycheck_treewidth(bnet) ;
