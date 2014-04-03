function marginal = marginal_nodes_from_pot(engine, query, evidence)

bnet = bnet_from_engine(engine) ;
clpot = clpot_from_engine(engine) ;
seppot = seppot_from_engine(engine) ;

c = clq_containing_nodes(engine, query);
if c == -1
  error(['no clique contains ' num2str(query)]);
end

observed = find(~isemptycell(evidence)) ;

if ~isempty(observed)    
    if mysubset([observed query],clpot{c}.domain)
        clq = clpot{c} ;
        domain = clq.domain ;    
        common = myintersect(domain, observed) ;
        clpot{c} = absorb_pot_obs(clq,common,evidence) ;
        
        marginal = pot_to_marginal(marginalize_pot(clpot{c}, query));
        return ;
    end        
    
    N = length(clpot) ;
    for k=1:N
        clq = clpot{k} ;
        domain = clq.domain ;    
        common = myintersect(domain, observed) ;    

        % Absorbing given conditions for cliques that involving
        % observed variables only
        if ~isempty(common)             
            clpot{k} = absorb_pot_obs(clq,common,evidence) ;
        end
    end
    
    
    sepmeat = find(~cellfun('isempty',seppot)==1) ;
    n = length(sepmeat) ;
    for k=1:n
        sep = seppot{sepmeat(k)} ;
        domain = sep.domain ;    
        common = myintersect(domain, observed) ;    

        % Absorbing given conditions for cliques that involving
        % observed variables only
        if ~isempty(common)             
            seppot{sepmeat(k)} = absorb_pot_obs(sep,common,evidence) ;
        end
    end
    
    moption = 'sum' ;
    
    for n=engine.postorder %postorder(1:end-1)
        for p=engine.postorder_parents{n}
            clpot{p} = divide_by_pot(clpot{p}, seppot{p,n});
            seppot{p,n} = marginalize_pot(clpot{n}, engine.separator{p,n}, moption);
            clpot{p} = multiply_by_pot(clpot{p}, seppot{p,n});
        end
    end
    %[clpot, seppot] = collect_evidence(engine, clpot, seppot);
    [clpot, seppot] = distribute_evidence(engine, clpot, seppot);
end


marginal = pot_to_marginal(marginalize_pot(clpot{c}, query));

