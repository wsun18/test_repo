function lam_msg = CPD_to_lambda_disc(CPD, n, ps, lambda, pi_from_parent, p)
% CPD_TO_LAMBDA_Disc Compute lambda message (discrete node) sending back to
% its parent. It is based on the code in BNT
% lam_msg = CPD_to_lambda_msg(CPD, msg_type, n, ps, msg, p, evidence)
% Pearl p183 eq 4.52

T = prod_CPT_and_pi_disc(CPD, n, ps, pi_from_parent, p);
mysize = length(lambda);
lambda = dpot(n, mysize, lambda);
T = multiply_by_pot(T, lambda);
lam_msg = pot_to_marginal(marginalize_pot(T, p));
lam_msg = lam_msg.T;           

