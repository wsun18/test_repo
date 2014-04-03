function [clpot, seppot] = init_pot(engine, clqs, pots, pot_type, onodes, ndx)
% INIT_POT Initialise potentials with evidence (jtree_inf)
% function [clpot, seppot] = init_pot(engine, clqs, pots, pot_type, onodes)

cliques = engine.cliques;
bnet = bnet_from_engine(engine);
% Set the clique potentials to all 1s
C = length(cliques);
clpot = cell(1,C);
for i=1:C
  clpot{i} = mk_initial_pot(pot_type, cliques{i}, bnet.node_sizes(:), bnet.cnodes(:), onodes);
end

% Multiply on specified potentials
for i=1:length(clqs)
  c = clqs(i);
  clpot{c} = multiply_by_pot(clpot{c}, pots{i});
end

seppot = cell(C,C); % implicitely initialized to 1
for n=engine.postorder  
    for p=engine.postorder_parents{n}
        tp_dom = myintersect(clpot{p}.domain, clpot{n}.domain);
        seppot{p,n}.domain = tp_dom ;
        tp_sz = bnet.node_sizes(tp_dom) ; 
        if myintersect(tp_dom,onodes) % added 5/8/2013, to initialize the right size for separator.-wsun            
            %tp_sz(onodes) = 1 ; this is wrong, we have to find the right
            %index. Bug found on 7/4/2013, and fixed as below:
            map = find_equiv_posns(onodes, tp_dom);
            tp_sz(map) = 1 ;
        end        
        if length(tp_dom) > 1
            seppot{p,n}.T = ones(tp_sz) ;
        else
            seppot{p,n}.T = ones(tp_sz,1) ;
        end
        seppot{p,n}.sizes = tp_sz ;
    end
end 
