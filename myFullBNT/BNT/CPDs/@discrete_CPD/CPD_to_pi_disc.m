function pi = CPD_to_pi_disc(CPD, n, ps, pi_from_parent)
% this function is based on CPD_to_pi(CPD, msg_type, n, ps, msg, evidence)
% Pearl p183 eq 4.51
% but try to simplify the program 
% wsun, July 28, 2009

T = prod_CPT_and_pi_disc(CPD, n, ps, pi_from_parent);
pi = pot_to_marginal(marginalize_pot(T, n));
pi = pi.T(:);   

