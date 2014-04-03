function engine = POT_update_by_clpot(engine,clpot)
% This function is suppose to update all potentials based on changes on
% clpot only. 
% -wsun, 5/6/2013

seppot = seppot_from_engine(engine) ;

% propagate to update all cliques/separators potentials. 
[clpot, seppot] = collect_evidence(engine, clpot, seppot);
[clpot, seppot] = distribute_evidence(engine, clpot, seppot);

% Normalizing clique potentials
for i=1:length(clpot)
    [clpot{i}, ll(i)] = normalize_pot(clpot{i});
end

% Normalizing separator potentials, added on 11/7/2011, -wsun. 
% After adding this part of code, calculating the joint by (product of
% cliques potentials) / (product of separators potentials) returned correct
% results. :)
for n=engine.postorder  
    for p=engine.postorder_parents{n}
        seppot{p,n} = normalize_pot(seppot{p,n});
    end
end   
% set_fields(engine,'clpot',clpot) ;
% set_fields(engine,'seppot',seppot) ;
engine.clpot = clpot ;
engine.seppot = seppot ;
