
function CPD = icpd2cpd(bnet, node, ICPD) ;
% we transform ICPD of a Gaussian node to its CPD in 
% the network after absorbing evidence

ncom = numel(ICPD) ;   % number of elements in ICPD, i.e., number of discrete combinations
%sz = size(ICPD) ;           % size of ICPD

re_ICPD = reshape(ICPD, 1, ncom) ;    % reshape ICPD to a row array

for k=1:length(re_ICPD)
    mu(k) = re_ICPD{k}.mu ;
    cov(k) = re_ICPD{k}.cov ;
    if isfield(re_ICPD, 'weights')
        weights(k) = re_ICPD{k}.weights ;
    end
end

if ~isfield(ICPD, 'weights')    
    CPD = gaussian_CPD(bnet, node, 'mean', mu, 'cov', cov) ;
else
    CPD = gaussian_CPD(bnet, node, 'mean', mu, 'cov', cov, 'weights', weights) ;
end

