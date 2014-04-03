function lam = prod_lambda_hybrid_gmm(msg_type, lambda_from_self, lambda_from_child, cs, except)

if nargin < 5, except = -1; end

lam_it = lambda_from_self;
switch msg_type
    case 'd'
        for i=1:length(cs)
            c = cs(i);
            if c ~= except
                lam = lam_it .* lambda_from_child{i};
                lam_it = lam;
            end
        end  
    case 'gm' %Oct.6th, 2010, I changed 'g' into 'gm', -wsun.
         % Product of lambda message in Gaussian cases, 
         % lambda message is represented by 'precision' and 'info_state'.
         % precision = 1/Sigma, info_state = mu/Sigma. Sigma is variance, not STD.
         %
         % see eq.(2.3.2-12) and eq.(2.3.2-13) on p94 in the book 
         % written by Bar-Shalom: "Estimation with Applications to 
         % Tracking and Navigation." 
        if isinf(lam_it.precision) % isfield(lam, 'observed_val'), this node is observed itself. 
            lam = lam_it ;
            return; 
        end
        
        for i=1:length(cs)            
            c = cs(i);
            %bug found from the following code - if continuous node has more
            %than one continuous child, then the computation for the first
            %child will have problem because lam is not defined. 
%             if c ~= except
%                 m = lambda_from_child{i};
%                 noc_it = length(lam_it.gmmprior); % number of Gaussian components, 9/30/09.
%                 noc_next = length(m.gmmprior);
%                 for j=1:noc_it
%                     for k=1:noc_next                                                
%                         lam.precision((j-1)*noc_next + k) = lam_it.precision(j) + m.precision(k);
%                         lam.info_state((j-1)*noc_next + k) = lam_it.info_state(j) + m.info_state(k);
%                         %lam.Sigma((j-1)*noc_next + k) = (lam.precision((j-1)*noc_next + k))^(-1);
%                         %lam.mu((j-1)*noc_next + k) = lam.Sigma((j-1)*noc_next + k) * ...
%                         %    lam.info_state((j-1)*noc_next + k) ;
%                         lam.weight((j-1)*noc_next + k) = lam_it.weight(j) * m.weight(k) ;
%                         lam.ratio((j-1)*noc_next + k) = lam_it.ratio(j) * m.ratio(k) ;
%                         lam.gmmprior((j-1)*noc_next + k) = lam_it.gmmprior(j) * m.gmmprior(k) ;
%                     end
%                 end
%             end
%             lam_it = lam ;
            % The following is the corrected code, -10/6/10, wsun.
            lam = lam_it ;
            if c ~= except
                m = lambda_from_child{i};
                noc_it = length(lam_it.weight); % number of Gaussian components, 9/30/09.
                noc_next = length(m.weight);
                for j=1:noc_it
                    for k=1:noc_next   
                        lam.weight((j-1)*noc_next + k) = lam_it.weight(j) * m.weight(k) ;
                        lam.ratio((j-1)*noc_next + k) = lam_it.ratio(j) * m.ratio(k) ;
                        lam.precision((j-1)*noc_next + k) = lam_it.precision(j) + m.precision(k);
                        lam.info_state((j-1)*noc_next + k) = lam_it.info_state(j) + m.info_state(k);                                               
                        %lam.gmmprior((j-1)*noc_next + k) = lam_it.gmmprior(j) * m.gmmprior(k) ;
                    end
                end
            end
            lam_it = lam ;
        end  
        %lam.gmmprior = lam.weight .* lam.ratio ; %2/15/10, wsun.
        %lam.gmmprior = lam.gmmprior / sum(lam.gmmprior) ; %normalization. 10/16/09.
end



