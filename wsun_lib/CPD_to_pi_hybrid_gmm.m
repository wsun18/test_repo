
function pi = CPD_to_pi_hybrid_gmm(msg_type, CPD, n, ps, cnodes, pi_from_parent) 

%% compute the pi value of a node given its CPD and pi messages sent from
%% its parents. 

switch msg_type
    case 'd' % for discrete node
        pi = CPD_to_pi_disc(CPD, n, ps, pi_from_parent) ;
        %pi = CPD_to_pi(CPD, pi_from_parent) ;
    case 'gm' % for continuous node, %Oct.6th, 2010, I changed 'g' into 'gm', -wsun.
        if mysubset(ps, cnodes) % continuous node has continuous parents only
            %pi = CPD_to_pi_ukf(CPD, pi_from_parent);
            pi = CPD_to_pi_pcp_gmm(CPD, pi_from_parent);
            return;
        end
        
        if isempty(myintersect(ps, cnodes)) % continuous node has discrete parents only
            % -wsun, 11/16/10. modified code to handle more than one
            % discrete parents and returned pi in GMM format.
            pi = CPD_to_pi_pdp_gmm(CPD, pi_from_parent); 
            return;
        end
        
        % continuous node has both discrete and continuous parents
        %%pi = CPD_to_pi_mix(CPD, pi_from_parent);
        %%pi = CPD_to_pi_mix_gmm(CPD, pi_from_parent);
        pi = CPD_to_pi_mixparents_gmm(CPD, pi_from_parent); %-wsun (11/16/10), modified code capable to handle multiple discrete and continuous parents.
    otherwise
        error('wrong msg_type, it must be either d or g');
end