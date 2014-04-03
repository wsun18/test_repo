function marginal = marginal_nodes_from_clpot(clpot, query)
% MARGINAL_NODES Compute the marginal on the specified query nodes (jtree)
% marginal = marginal_nodes(engine, query, add_ev)
%
% 'query' must be a subset of some clique; an error will be raised if not.
% add_ev is an optional argument; if 1, we will "inflate" the marginal of observed nodes
% to their original size, adding 0s to the positions which contradict the evidence


marginal = pot_to_marginal(marginalize_pot(clpot, query));

