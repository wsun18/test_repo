function CPD = updateCPD_from_pot(engine)

bnet = bnet_from_engine(engine) ;
clpot = clpot_from_engine(engine) ;
seppot = seppot_from_engine(engine) ;
ns = bnet.node_sizes ;
N = length(ns) ;

for k=1:N 
    CPD = bnet.CPD{k} ;
    ps = bnet.parents{k} ;
    c = clq_containing_nodes(engine, k);
    if c == -1
        error(['no clique contains ' num2str(query)]);
    end
    if ~isempty(parent)
        evids = cell(1,N) ;
        par_sz = ns(parent) ;
        hcc = full_combination_new(par_sz) ;
        for j=1:size(hcc,1)
            instance = hcc(j,:) ;
            evids(parent) = num2cell(instance) ;
            %engine_temp = enter_evidence(engine_temp, evids) ;
            clpot{c} = enter_evidence_clpot(clpot{c},evids} ;
            marg = marginal_nodes_from_clpot(clpot{c}, k) ;
            tempT(j,:) = marg.T' ;
        end  
        CPD_sz = ns([parent k]) ;
        tempT = reshape(tempT, CPD_sz) ;
        bnet.CPD{k} = set_fields(CPD, 'userCPT', tempT) ;    
        tempT = [] ;
    else
        marg = marginal_nodes_from_clpot(clpot{c}, k) ;
        tempT = marg.T ;
        bnet.CPD{k} = set_fields(CPD, 'userCPT', tempT) ;
        tempT = [] ;
    end    
    
end

observed = find(~isemptycell(evidence)) ;
if ~isempty(observed)    
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



c = clq_containing_nodes(engine, query);
if c == -1
  error(['no clique contains ' num2str(query)]);
end

if engine.maximize == 1
    moption = 'max'; 
else if engine.minimize == 1
        moption = 'min'; 
    else
        moption = 'sum';
    end
end
marginal = pot_to_marginal(marginalize_pot(clpot{c}, query, moption));

