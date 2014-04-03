function lk = obs_likelihood(CPD, obs, pev)
% written on Jan.24, 2007 --- WSUN
% compute the likelihood of a node observed.
%
% pev{i} is the value of the i'th parent (if there are any parents)

if length(CPD.dps)==0
  i = 1;
else
  dpvals = cat(1, pev{CPD.dps});
  i = subv2ind(CPD.sizes(CPD.dps), dpvals(:)');
end

obs = cat(1,obs{:}) ;
%pev = cat(1,pev{:}) ;

% updated on 3/19/2012 (wsun), to handle cases with multiple discrete
% parents
if ~isempty(CPD.function)
    x = cat(1, pev{CPD.cps});
    func = CPD.function ;
    var_names = CPD.variables(1:end-1) ;
    tmu = CPD.mean + subs(func{i}, var_names, x) ;  % specify the right function (wsun), I used 'func{i}' to replace previous 'func'
    tSigma = CPD.cov(:,:,i) ;
    lk = normpdf(obs, tmu, sqrt(tSigma)) ;
else
    tmu = CPD.mean(:,i) + CPD.weights(:,:,i)*pev(CPD.cps) ;
    lk = normpdf(obs, tmu, sqrt(CPD.cov(:,:,i))) ;
end



