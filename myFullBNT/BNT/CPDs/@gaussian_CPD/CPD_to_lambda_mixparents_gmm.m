
%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%
% -wsun, 11/16/10. 
% modified the code to have it capable to handle the continuous node with
% more than one discete parents and whatever many continuous parents.
% Also changed the function name from the previous 
% CPD_to_lambda_mix_gmm(CPD, ps, lambda, pi_from_parent,p)
% to 
% CPD_to_lambda_mixparents_gmm(CPD, ps, lambda, pi_from_parent,p).
%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%
% Aug.2, 2009
% Based on CPD_to_lambda_ukf
% This function is to handle the case for a continuous node that has both
% discrete and continuous parents. This function compute the lambda message
% sent from the continuous node to one of its parent, which is either a
% discrete parent or a continuous parent.
% ps: all parents nodes of the current node, assume that the first element
% in ps is the only discrete parent.
% p: the one parent we are sending lambda message.
%
% CPD.cps is the index for cts parents, not the real domains.
% To find the index of the excepted parent to which we are sending lambda
% messages among all cts parents. 
%
% The first element in 'pi_from_parent' is for the only discrete parent.
%%%%%%%%%%%%%%%=====================================%%%%%%%%%%%%%%%%%%%%%%%


function lam_msg = CPD_to_lambda_mixparents_gmm(CPD, ps, lambda, pi_from_parent, p) 

dps = ps(CPD.dps); % discrete parents
cps = ps(CPD.cps); % continuous parents
ip = find_equiv_posns(p, ps); % p is the ip'th parent for the current node.
nodp = length(dps) ; % number of discrete parents
dns = CPD.sizes(1:nodp) ; % nodes sizes of all discrete parents.
dcc = full_combination(dns) ;

if all(lambda.precision == 0) % no info to send 
    if mysubset(p,dps) %for message sending to one discrete parent        
        dpsz = CPD.sizes(ip); 
        lam_msg = ones(dpsz,1);
    else % for any continuous parents           
        lam_msg = lambda ;
%         cpsz = CPD.sizes(ip) ;
%         lam_msg.weight = lambda.weight ;
%         lam_msg.ratio = lambda.ratio;
%         lam_msg.gmmprior = lambda.gmmprior;
%         lam_msg.precision = zeros(cpsz, cpsz);
%         lam_msg.info_state = zeros(cpsz, 1);        
    end
    return;
end

%%%%%%%%%%%%% ======================= %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% lambda has something to send %%%%%%%%%%%%%

if mysubset(p,dps) %for message sending to one discrete parent  
    if isinf(lambda.precision) % current node,from which lambda message is sent, is observed.
        self_size = CPD.sizes(end);
        temp_lam.weight = lambda.weight ;
        temp_lam.ratio = lambda.ratio ;
        temp_lam.mu = lambda.mu; % observed_value;
        temp_lam.Sigma = zeros(self_size, self_size); % infinite precision => 0 variance    
    else % not observed but has some information
        temp_lam.weight = lambda.weight ;
        temp_lam.ratio = lambda.ratio ;        
        temp_lam.Sigma = lambda.precision .^ (-1) ;
        temp_lam.mu = temp_lam.Sigma .* lambda.info_state ;
    end
    
    dpsz = CPD.sizes(ip); 
    
    % initialization
    for k=1:dpsz
        temp_pi(k).gmmprior = []; 
        temp_pi(k).mu = []; 
        temp_pi(k).Sigma = []; 
    end
    
    for i=1:size(dcc,1)        
        mixing_prior = 1;
        for j=1:nodp
            if ip ~= j
                mixing_prior = mixing_prior * pi_from_parent{j}(dcc{i,j}); 
            end
        end
        
        tempCPD = CPD ;
        tempCPD.mean = CPD.mean(i);
        tempCPD.cov = CPD.cov(i);
        tempCPD.function = CPD.function(i);    
        tempCPD.dps = [];
        tempCPD.cps = CPD.cps - nodp ;
        tempCPD.sizes = CPD.sizes(nodp+1:end);

        tempPiFromParent = pi_from_parent(nodp+1:end) ;

        tempPi = CPD_to_pi_pcp_gmm(tempCPD, tempPiFromParent) ;

        tempPi.gmmprior = mixing_prior * tempPi.gmmprior ;

        nogc = length(tempPi.gmmprior) ; % number of gaussian components.
        temp_pi(dcc{i,ip}).gmmprior(end+1:end+nogc) = tempPi.gmmprior ;
        temp_pi(dcc{i,ip}).mu(end+1:end+nogc) = tempPi.mu ;
        temp_pi(dcc{i,ip}).Sigma(end+1:end+nogc) = tempPi.Sigma ;  
    end
    
    temp_lam.gmmprior = temp_lam.weight .* temp_lam.ratio ;
    for k=1:dpsz
        lam_msg(k) = int_prod_gaussian_gmm(temp_lam, temp_pi(k));       
    end

    lam_msg = lam_msg' ;
    return;     
    
end

%%%%%%% ====================== %%%%%%%%%%%%%%%%%%%
% for sending lambda msg to any continuous parent   

% initializing lam_msg
%lam_msg.gmmprior = [];   
lam_msg.weight = [];
lam_msg.ratio = [];
lam_msg.info_state = [];
lam_msg.precision = [];

for i=1:size(dcc,1)        
    mixing_prior = 1;
    for j=1:nodp
        mixing_prior = mixing_prior * pi_from_parent{j}(dcc{i,j});        
    end

    tempCPD = CPD ;
    tempCPD.mean = CPD.mean(i);
    tempCPD.cov = CPD.cov(i);
    tempCPD.function = CPD.function(i);    
    tempCPD.dps = [];
    tempCPD.cps = CPD.cps - nodp ;
    tempCPD.sizes = CPD.sizes(nodp+1:end);

    tempPiFromParent = pi_from_parent(nodp+1:end) ;
    
    % -wsun, 11/22/10: pay attention, here we have cps,lambda, etc. as
    % arguments passing into the function shown as below:
    tempLam = CPD_to_lambda_pcp_gmm(tempCPD, cps, lambda, tempPiFromParent, p) ;

    tempLam.weight = mixing_prior * tempLam.weight;
    %tempLam.gmmprior = tempLam.weight .* tempLam.ratio ;

    nogc = length(tempLam.weight) ; % number of gaussian components.
    %lam_msg.gmmprior(end+1:end+nogc) = tempLam.gmmprior ;
    lam_msg.weight(end+1:end+nogc) = tempLam.weight ;
    lam_msg.ratio(end+1:end+nogc) = tempLam.ratio ;      
    lam_msg.info_state(end+1:end+nogc) = tempLam.info_state ;
    lam_msg.precision(end+1:end+nogc) = tempLam.precision ;
end
      

 

 
