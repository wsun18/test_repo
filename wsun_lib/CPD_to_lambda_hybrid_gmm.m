
function lam_msg = CPD_to_lambda_hybrid_gmm(msg_type, CPD, n, ps, cnodes, lambda, pi_from_parent, p) 

%% compute the pi value of a node given its CPD and pi messages sent from
%% its parents. 

switch msg_type
    case 'd' % for discrete node
        lam_msg = CPD_to_lambda_disc(CPD, n, ps, lambda, pi_from_parent, p) ;
        %pi = CPD_to_pi(CPD, pi_from_parent) ;
    case 'gm' % for continuous node, %Oct.6th, 2010, I changed 'g' into 'gm', -wsun.
        % for case that this node has continuous parents only
        % pcp: pure continuous parent, 9/29/09
        if mysubset(ps, cnodes) % for case that this node has continuous parents only
            %lam_msg = CPD_to_lambda_ukf(CPD, ps, lambda, pi_from_parent, p);
            lam_msg = CPD_to_lambda_pcp_gmm(CPD, ps, lambda, pi_from_parent, p);
            return;
        end

        % continuous node has discrete parents only (pdp - pure discrete parents) 
        if isempty(myintersect(ps, cnodes)) 
            lam_msg = CPD_to_lambda_pdp(CPD, ps, lambda, pi_from_parent, p); 
            return;
        end
        
        % for case that this node has mixed discrete and continuous parents
        %lam_msg = CPD_to_lambda_mix(CPD, ps, lambda, pi_from_parent, p);
        %lam_msg = CPD_to_lambda_mix_gmm(CPD, ps, lambda, pi_from_parent, p);
        % -wsun, 11/20/10, modified code to accommodate whatever
        % combination of discrete and continuous parents. 
        lam_msg = CPD_to_lambda_mixparents_gmm(CPD, ps, lambda, pi_from_parent, p);
    otherwise
        error('wrong msg_type, it must be either d or g');
end