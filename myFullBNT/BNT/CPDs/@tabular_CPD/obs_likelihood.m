function lk = obs_likelihood(CPD, obs, pev)
% written on Feb.15, 2007 --- WSUN
% compute the likelihood of a discrete node observed.
%
% pev{i} is the value of the i'th parent (if there are any parents)

% obs = cat(1,obs{:}) ;
% pev = cat(1,pev{:}) ;

cpt = CPD_to_CPT(CPD) ;

% lk = cpt(pev{:},obs{:}) ;

sz = size(cpt) ;
rcpt = reshape(cpt, prod(sz),1) ;

index = pev{1} ;
sw = 1 ;
for k=2:length(pev)
    sw = sw*sz(k-1) ;
    index = index + (pev{k}-1)*sw ;
end
sw = sw*sz(end-1) ;
index = index + (obs{:}-1)*sw ;

lk = rcpt(index,1) ;
