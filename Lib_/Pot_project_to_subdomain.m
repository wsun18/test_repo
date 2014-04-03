function subpot = Pot_project_to_subdomain(pot,subdom)

%% This is to compute the joint probability over its sub domain from the
%% original joint probability

assert(mysubset(subdom, pot.domain)) ;

subpot = marginalize_pot(pot,subdom) ;
%subjointp = subpot.T(:) ;

