function [test_bnet tw] = mk_bnet_fromAlarm(n,start)
% 12/06/2012, create a n-node BN from the 37-node model Alarm. The starting node
% can be chosen from the first node or randomly specified by one of the 37
% nodes.
% -wsun

% Alarm is a network borrowed from BeinlichSCC89.
% Alarm stands for 'A Logical Alarm Reduction Mechanism'. It is a medical
% diagnostic system for patient monitoring.
% Alarm has 37 nodes in total, with 8 diagoses, 16 finds, and 13
% intermediate variables.
% Beinlich, I., Suermondt, G., Chavez, R., and Cooper, G. "The Alarm
% Monitoring System: A Case Study with Two Probabilistic Inference
% Techniques for Belief Networks". In Proceedings of 2nd European
% Conference on AI and Medicine, 1989.

if nargin < 2, start=1; end

bnet = mk_alarm_bnet('orig'); 

%tw_alarm = mycheck_treewidth(bnet) ; 

dag = bnet.dag ;
node_sizes = bnet.node_sizes ;
node_names = bnet.node_names ;

curr_node = start ;
if strcmp(start,'random')
    curr_node = unidrnd(37) ;
end

temp = find(dag(curr_node,:)>0) ;
tp_ps = [] ;
candchd_set = [] ;
candps_set = [] ;
if length(temp)>1
    next = temp(1) ;
    candchd_set = [candchd_set temp(2:end)] ;
end
curr_set = [curr_node next] ;
for k=temp 
    ttp = mysetdiff(find(dag(:,k)>0)',curr_set) ;
    ttp = mysetdiff(ttp,tp_ps) ;
    tp_ps = [tp_ps ttp] ;
end
candps_set = [candps_set tp_ps] ;

NN = n ;
dnodes = 1:NN ;
new_dag = zeros(NN,NN) ;
while length(curr_set) < NN
    candchd_set = mysetdiff(candchd_set, myintersect(candps_set,candchd_set)) ;
    if ~isempty(candps_set)
        next = candps_set(1) ;
        candps_set = mysetdiff(candps_set,next) ;        
    else
        next = candchd_set(1) ;
        candchd_set = mysetdiff(candchd_set,next) ;                  
    end
    candps_set = [candps_set mysetdiff(find(dag(:,next)>0)',[curr_set candps_set])] ; 
    candchd_set = [candchd_set mysetdiff(find(dag(next,:)>0),[curr_set candchd_set])] ; 
        
    curr_set = sort([curr_set next]) ;    
end

new_dag = dag(curr_set,curr_set) ;
ns = node_sizes(curr_set) ;

test_bnet = mk_bnet(new_dag, ns, 'discrete', dnodes, 'names', bnet.node_names(curr_set));

% specify uniform  CPDs for all nodes
for k=1:NN
    test_bnet.CPD{k} = tabular_CPD(test_bnet, k,'CPT','unif') ;
end

tw = mycheck_treewidth(test_bnet) ;
