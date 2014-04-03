function bnet = mk_alarm_bnet(CPD_type)
% ALARM: used in the paper \cite{BSC89} to compare various inference
% algorithms. I.~Beinlich, G.~Suermondt, R.~Chavez, and G. ~Cooper.
% "The Alarm Monitoring System: A Case Study with Two Probabilistic 
% Inference Techniques for Belief Networks". In Proc. 2'nd European 
% Conf. on AI and Medicine, 1989.

% Written by Qian Diao <qian.diao@intel.com> on 11 Dec 01

if nargin == 0, CPD_type = 'rnd'; end

N = 37;
dag = zeros(N,N);
dag(21,23) = 1 ;
dag(21,24) = 1 ;
dag(1,24) = 1 ;
dag(1,23) = 1 ;
dag(2,26) = 1 ;
dag(2,25) = 1 ;
dag(2,24) = 1 ;
dag(2,13) = 1 ;
dag(2,23) = 1 ;
dag(13,30) = 1 ;
dag(30,31) = 1 ;
dag(3,14) = 1 ;
dag(3,19) = 1 ;
dag(4,36) = 1 ;
dag(14,35) = 1 ;
dag(32,33) = 1 ;
dag(32,35) = 1 ;
dag(32,34) = 1 ;
dag(32,36) = 1 ;
dag(15,21) = 1 ;
dag(5,31) = 1 ;
dag(27,30) = 1 ;
dag(28,31) = 1 ;
dag(28,29) = 1 ;
dag(26,28) = 1 ;
dag(26,27) = 1 ;
dag(16,31) = 1 ;
dag(16,37) = 1 ;
dag(23,26) = 1 ;
dag(23,29) = 1 ;
dag(23,25) = 1 ;
dag(6,15) = 1 ;
dag(7,27) = 1 ;
dag(8,21) = 1 ;
dag(19,20) = 1 ;
dag(19,22) = 1 ;
dag(31,32) = 1 ;
dag(9,14) = 1 ;
dag(9,17) = 1 ;
dag(9,19) = 1 ;
dag(10,33) = 1 ;
dag(10,34) = 1 ;
dag(11,16) = 1 ;
dag(12,13) = 1 ;
dag(12,18) = 1 ;
dag(35,37) = 1 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% randomly choose the node to be continuous or discrete
%%% only requirement is that no continuous parent for discrete node.
cnodes = [] ; 
dnodes = [] ;
for i=1:N
    if intersect(find(dag(:,i)), cnodes)
        cnodes = [cnodes, i] ; % it has to be continuous node if it has continuous parents.
    else
        if rand > .1
            dnodes = [dnodes, i] ;
        else 
            cnodes = [cnodes, i] ;
        end
    end
end

node_sizes = ones(1,N) ;
node_sizes(dnodes) = 2 ;
        
node_names = cell(1, N) ;
for i=1:N
    node_names{i} = strcat('nod', int2str(i)) ;
end
    
bnet = mk_bnet(dag, node_sizes, 'discrete', dnodes, 'names', node_names);

for k=dnodes
    bnet.CPD{k} = tabular_CPD(bnet, k) ;
end

for i=cnodes(:)'
    bnet.CPD{i} = gaussian_CPD(bnet, i);
end


        
