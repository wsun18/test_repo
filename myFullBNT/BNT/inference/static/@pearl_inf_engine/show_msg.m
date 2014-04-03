

%function s = show_msg(bnet, msg)

N = length(bnet.node_sizes) ;
disp('Messages for all nodes')
for j=1:N
    disp(['*** ' bnet.node_names{j}])
    disp('pi message')
    msg{j}.pi
    
    for k=1:length(bnet.parents{j})        
        pn = ['pi from parent - ' bnet.node_names{bnet.parents{j}(k)}] ;
        disp(pn)
        msg{j}.pi_from_parent{k}
    end
    
    disp('lambda message')
    msg{j}.lambda
    
    for k=1:length(bnet.children{j})        
        pn = ['lambda from child - ' bnet.node_names{bnet.children{j}(k)}] ;
        disp(pn)
        msg{j}.lambda_from_child{k}
    end
    
    disp('lambda_from_self')
    msg{j}.lambda_from_self
    disp('----------------')
end