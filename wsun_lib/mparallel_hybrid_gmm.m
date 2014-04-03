
% Oct.6th, 2010
% I modified the previous version of the same program
% 'mparallel_hybrid_gmm.m', quite a few things changed as below:
% (1) all continuous message changed to 'gm' from the previous 'g';
% (2) all code are reorganized to be neat;
% (3) pi message sent to child is computed in a new simple way as a product
% of gaussian mixture

% July 28, 2009
% Message propagation in parallel between hybrid nodes in CHM (Conditioned
% Hybrid Model). It is designed to be able to pass message directly between
% discrete node and continuous node. (Only restriction is that no
% continuous parent for any discrete node)
% 
% This program is based on mparallel_gauss2
%
% Jan.20, 2007
% The only difference between mparallel_gauss1 and mparallel_gauss2 is the
% message updating order. mparallel_gauss1 follows the same order as in BNT
% pearl's belief propagation; mparallel_gauss2 is according to my thinking,
% which I think better and efficient, it updates pi, lambda messages as
% well as all sending messages one node by one node in one iteration.

function [msg bel iter] = mparallel_hybrid_gmm(bnet, evidence)
% each node maintains the following messages:
% A.pi
% A.lambda
% A.pi_from_parent
% A.lambda_from_child
% A.lambda_from_self
% every 'pi' message is represented by 'mu', and 'Sigma'; 
% every 'lambda' message is represented by 'info_state' and 'precision'.
% 'info_state' is defined as 'mu/Sigma', 'precision' is the inverse 
% variance, representing how accurate the information.
% see eq.(2.3.2-12) and eq.(2.3.2-13) on p94 in the book written by
% Bar-Shalom: "Estimation with Applications to Tracking and Navigation."

dag = bnet.dag ;
N = length(dag) ;
ns = bnet.node_sizes(:);

cnodes = bnet.cnodes;
dnodes = bnet.dnodes;
hidden = find(isemptycell(evidence)); 
bel = cell(1, N) ;
old_bel = cell(1, N) ;

% message initialization
msg = init_msgs(bnet, ns, evidence) ;

%%%%%%%%%%%%%%%%%
% To show the initial messages for every node
% disp('Message Initialization:') ;
% show_msg(bnet, msg, 0) ;
% end to show the initial message.

% maxiter = 2*N + 2 ;
% hidden = find(isemptycell(evidence));
% old_bel = cell(1,N) ;
% bel = cell(1,N) ;
% for k=1:N ;
%     bel{k} = zeros(bnet.node_sizes(k),1)  ;
% end
% change = 1 ;
% iter = 1 ;
% 
% threh = .001 ;  % the tolerance BNT Pearl_inf_engine uses is 0.001
% 
% while change == 1 && iter < maxiter

thresh = 1e-3 ;
change = 1 ;
iter = 1 ;
maxiter = 66 ;
while iter <= maxiter    
    if iter > 2
        change = 0 ;
    end    
    %fprintf('------- Iteration %g ----------\n', iter) ;
    for i=1:N  % node i
        nm = bnet.node_names{i} ;   % node name.
        ps = bnet.parents{i} ; % Node i's parents.                        
        cs = bnet.children{i} ; % node i's children. 
        %fprintf('- Now serving node %s \n', nm) ;
        % messages update
        
        % The updated lambda value of A node is the product of A.lambda_from_self
        % and all lambda messages sent from its each child. 
        % -If the node is a continuous node, it won't have any discrete
        % child in CHM. In Gaussian case, see eq.(2.3.2-12) and
        % eq.(2.3.2-13) on p94 in the book written by Bar-Shalom: 
        % "Estimation with Applications to Tracking and Navigation." 
        % -If the node is a discrete node, it may have both discrete and
        % continuous children. However, the lambda messages sent from
        % either its discrete or continuous child will be in the same
        % format as a discrete vector. 
        
        if myintersect(i, cnodes)
            msg_type = 'gm';
        else
            msg_type = 'd';
        end
        lam_msg = msg{i}.lambda_from_self ; 
        lam_from_child = msg{i}.lambda_from_child ;        
        
        if ~isempty(cs)             
            lam_msg = prod_lambda_hybrid_gmm(msg_type, lam_msg, lam_from_child, cs) ;  
        end
        msg{i}.lambda = lam_msg ;
        
        %fprintf('-updating %s.lambda: \n', nm) ;
        %disp(msg{i}.lambda) ;
        
        % The updated pi value of A node is to be computed by using 
        % unscented Kalman filter.
        if mysubset(i,hidden) %modified on 12/06/10 by wsun - if this node is hidden, no need to compute its pi value. 
            if isempty(ps)            
                %msg{i}.pi = pi_from_prior(msg_type, bnet.CPD{i});
                msg{i}.pi = pi_from_prior_gmm(msg_type, bnet.CPD{i});
                %msg{i}.pi.mu = get_field(bnet.CPD{i},'mean') ;
                %msg{i}.pi.Sigma = get_field(bnet.CPD{i}, 'cov') ; 
            else
                %f = get_field(bnet.CPD{i}, 'function') ;
                pi_from_parent = msg{i}.pi_from_parent ;                        
                %msg{i}.pi = CPD_to_pi_ukf(bnet.CPD{i}, pi_from_parent) ;
                %msg{i}.pi = CPD_to_pi_hybrid(msg_type, bnet.CPD{i}, i, ps, ...
                %    cnodes, pi_from_parent) ; %capable to handle mixed parents
                msg{i}.pi = CPD_to_pi_hybrid_gmm(msg_type, bnet.CPD{i}, i, ps, ...
                    cnodes, pi_from_parent) ; %capable to handle mixed parents and keep exact msg.
            end
            %fprintf('-updating %s.pi: \n', nm) ;
            %disp(msg{i}.pi) ;    
        end
                
        % lambda messages sending to parents                        
        for p=ps
            pnm = bnet.node_names{p} ;
            % Pearl's book p183, eq4.52.
            j = find_index(i, bnet.children{p}) ; % Node i is Node p's jth child.

            % product of pi messages sent from all parents except parent
            % 'p' because we are computing the lambda message sending to
            % it. If 'p' is the only parent of Node i, then it is easy that
            % we don't have to multiply pi messages from other parents.            
            %lam_msg = CPD_to_lambda_ukf(bnet.CPD{i}, ps, msg{i}.lambda, ...
            %    msg{i}.pi_from_parent, p) ;
            lam_msg = CPD_to_lambda_hybrid_gmm(msg_type, bnet.CPD{i}, i, ps, ...
                cnodes, msg{i}.lambda, msg{i}.pi_from_parent, p) ;
            msg{p}.lambda_from_child{j} = lam_msg ;
            %fprintf('-updating %s.lambda_from_child(%s): \n', pnm, nm) ;
            %disp(msg{p}.lambda_from_child{j}) ;
        end

        % pi messages sending to children        
        for c=cs                  
            cnm = bnet.node_names{c} ;
            j = find_index(i, bnet.parents{c}) ; % Node i is Node c's jth parent.            
            % if 'c' is Node i's only child, then the 'pi' message
            % sending to this unique child is just  the pi value of i
            % itself multiplied by the lambda message from 'i' itself.
            lam_self = msg{i}.lambda_from_self ;
            if length(cs) == 1                 
                pi_msg = prod_pi_lambda_hybrid_gmm(msg_type, msg{i}.pi, lam_self)  ;
            else   % if Node i has more than one child.
                % product of lambda messages from all children except c because
                % we are computing the pi message sending to it.
                lambda_from_child = msg{i}.lambda_from_child ;
                plam = prod_lambda_hybrid_gmm(msg_type, lam_self, lambda_from_child, cs, c) ;                 
                pi_msg = prod_pi_lambda_hybrid_gmm(msg_type, msg{i}.pi, plam) ;
            end
            msg{c}.pi_from_parent{j} = pi_msg ;
            %fprintf('-updating %s.pi_from_parent(%s): \n', cnm, nm) ;
            %disp(msg{c}.pi_from_parent{j}) ;            
        end
        %fprintf('    * \n') ;
        % end for computing all messages for Node i.
    end 
    
    % update the belief for hidden node
    for h=hidden
        if myintersect(h, cnodes)
            msg_type = 'gm';
        else
            msg_type = 'd';
        end
        old_bel{h} = bel{h} ;
        %bel{i} = compute_bel_gauss(msg{i}.pi, msg{i}.lambda) ;
        %bel{i} = compute_bel_hybrid(msg_type, msg{i}.pi, msg{i}.lambda) ;
        bel{h} = compute_bel_hybrid_gmm(msg_type, msg{h}.pi, msg{h}.lambda) ;
        if iter > 2 % assume continous with size 1 for all nodes
            %change = max(change, abs(bel{i}.mu - old_bel{i}.mu)) ;
            %change = max(change, abs(bel{i}.Sigma - old_bel{i}.Sigma)) ;
            change = max(change, eval_change(msg_type, bel{h}, old_bel{h}));
            %fprintf('belief change: %g\n', change) ;                           
        end
        %fprintf('-updating %s.bel: \n', nm) ;
        %disp(bel{i}) ;
    end
    
    if change < thresh 
        fprintf('\n   Direct Message Passing - Number of iterations is: %g \n', iter) ;
        return; 
    end 
    iter = iter + 1 ;
    % show_msg(bnet, msg, iter) ;
    % show_bel(bnet, bel, iter) ;  
end


%%%%%%%%%%%

function msg =  init_msgs(bnet, ns, evidence)
% INIT_MSGS Initialize the lambda/pi message and state vectors
% msg =  init_msgs(bnet, ns, evidence)
%

dag = bnet.dag;
cnodes = bnet.cnodes;
dnodes = bnet.dnodes;
N = length(dag);
msg = cell(1,N);
observed = ~isemptycell(evidence);
lam_msg = 1;

for n=1:N
  ps = parents(dag, n);
  msg{n}.pi_from_parent = cell(1, length(ps));
  for i=1:length(ps)
    p = ps(i);
    % The pi message sent from A node's parent is solely depending on the
    % type of a particular parent node. If this parent is discrete, no
    % matter if this node itself is continuous or discrete, the pi message
    % sent from a discrete parent will be always in discrete format as a
    % vector. But if this parent is continuous, it can only have continuous
    % child, and so the pi message sent from a continuous parent will be
    % always in continuous format represented by mean and variance.
    if myintersect(p, cnodes)
        msg_type = 'g';
    else
        msg_type = 'd';
    end
    msg{n}.pi_from_parent{i} = mk_msg(msg_type, ns(p));
  end
  
  % Lambda value of A node and lambda message sent from A node's children will 
  % determined solely by the type of this node. If this node is discrete,
  % no matter if it has continuous child, the lambda message sent from its
  % children will be always in the format of discrete vector. 
  if myintersect(n, cnodes)
      msg_type = 'g';
  else
      msg_type = 'd';
  end
  cs = children(dag, n);
  msg{n}.lambda_from_child = cell(1, length(cs));
  for i=1:length(cs)
    c = cs(i);    
    msg{n}.lambda_from_child{i} = mk_msg(msg_type, ns(n), lam_msg);
  end

  msg{n}.lambda = mk_msg(msg_type, ns(n), lam_msg);
  msg{n}.pi = mk_msg(msg_type, ns(n));
  
  if observed(n)
    msg{n}.lambda_from_self = mk_msg_with_evidence(msg_type, ns(n), evidence{n});
  else
    msg{n}.lambda_from_self = mk_msg(msg_type, ns(n), lam_msg);
  end
end



%%%%%%%%%

function msg =  mk_msg(msg_type, sz, is_lambda_msg)

if nargin < 3, is_lambda_msg = 0; end

switch msg_type
 case 'd', msg = ones(sz, 1);
 case 'g', 
  if is_lambda_msg   
      %msg.gmmprior = 1;   
      msg.weight = 1;
      msg.ratio = 1;      
      msg.info_state = zeros(sz, 1);
      msg.precision = zeros(sz, sz);
  else
      msg.gmmprior = 1 ;    
      msg.Sigma = zeros(sz, sz);
      msg.mu = zeros(sz,1);      
  end
end

%%%%%%%%%%%%

function msg = mk_msg_with_evidence(msg_type, sz, val)

switch msg_type
 case 'd',
  msg = zeros(sz, 1);
  msg(val) = 1;
 case 'g',
  %msg.observed = val(:);  
  msg.weight = 1 ;
  msg.ratio = 1 ;
  msg.mu = val(:) ;    
  msg.precision = inf;  
end


%%%%%%%%%%%%%%%%%%%%%
function j = find_index(i, vt) 
 % i is one element in vt which is a vector
 % return j which is the index of i in vt.
 % assume there is only one i in vt, no repeat.
 % example is the best explanation
 % i=3, vt=[2 3 5]
 % then j=2.
 
 for k=1:length(vt)
     if i == vt(k)
         j = k ;
         return ;
     end
 end
 
 error('error, i is not in vt')