
function msg = prod_pi_lambda_hybrid_gmm(msg_type, pi,lambda)
% product of two Gaussian mixture is another Gaussian mixture with
% increased number of components, and mixing priors are changed accordingly. 
% 2/19/10, wsun.

% 10/06/10, wsun - always need to convert fields in lambda into 'mu', and
% 'Sigma'. and the code is almost completely rewritten.

switch msg_type
    case 'd'
        msg = normalise(pi .* lambda);
    case 'gm'
        if all(lambda.precision==0) % lambda has no information
            msg = pi;
            return;
        end
        
        if all(lambda.precision==inf) % ignore pi because lambda is completely certain (observed)
            msg.mu = lambda.mu;
            msg.Sigma = zeros(1,length(msg.mu)); % infinite precision => 0 variance
            msg.gmmprior = ones(1,length(msg.mu)); 
            return ;
        end

        lambda.Sigma = lambda.precision .^(-1) ;
        lambda.mu = lambda.Sigma .* lambda.info_state ;

        g1 = pi;
        g2 = lambda; 

        n1 = length(g1.gmmprior) ;  
        n2 = length(g2.gmmprior) ;
        for i=1:n1
            c1.mu = g1.mu(i);
            c1.Sigma = g1.Sigma(i);
            for j=1:n2
                c2.mu = g2.mu(j);
                c2.Sigma = g2.Sigma(j);
                tp = prod_2gaussian(c1, c2); 
                nconst = int_prod_gaussian(c1,c2); %normalization constant when multiply two single Gaussians.     
                mixing = nconst * g1.gmmprior(i) * g2.gmmprior(j);
                msg.gmmprior((i-1)*n2 + j) = mixing ;
                msg.mu((i-1)*n2 + j) = tp.mu;
                msg.Sigma((i-1)*n2 + j) = tp.Sigma;
            end
        end
        msg.gmmprior = msg.gmmprior/sum(msg.gmmprior); %normalization        
    otherwise
        error('wrong msg_type')
end


