
%% July 28, 2009
%% Get prior as the pi value for either discrete node or continuous node in CHM

function pi = pi_from_prior_gmm(msg_type, CPD)

switch msg_type
    case 'd'
        pi = get_field(CPD,'cpt');
    case 'gm' %Oct.6th, 2010, I changed 'g' into 'gm', -wsun.
        pi.gmmprior = 1 ;
        pi.mu = get_field(CPD,'mean') ;
        pi.Sigma = get_field(CPD, 'cov') ;
    otherwise
        error('msg_type much be either d or g') ;
end