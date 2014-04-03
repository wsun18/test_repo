function mpe = max_calib_withCompiledNet(engine, evidence)
% This is to find the MPE by running max-calibration for a compiled
% network, namely, we already have normalized clique potentials (which is
% actually joint probability distributions for all cliques).
% The argument 'engine' has compiled 'clpot' and 'seppot' saved
% inside, that are results provided by regular sum-product Junction tree
% algorithm.
% Dec.5, 2011
% -wsun

clpot = engine.clpot ;
seppot = engine.seppot ;
nc = length(clpot) ; % number of cliques

engine.maximize = 1; %to make sure to run max-calibration
[clpot, seppot] = collect_evidence(engine, clpot, seppot);
[clpot, seppot] = distribute_evidence(engine, clpot, seppot);

% max-normalization
for i=1:nc
    clpot{i}.T = clpot{i}.T / max(clpot{i}.T(:)) ;
end

c1 = clpot{1} ;
d1 = c1.domain ;
js1 = full_combination_new(c1.sizes) ;
ind = find(c1.T==1) ;
for k=1:length(ind)
    min1(k,d1) = js1(ind(k),:); 
end

consistency = 0 ;

for i=2:nc
    c2 = clpot{i} ;
    d2 = c2.domain ;
    js2 = full_combination_new(c2.sizes) ;
    ind = find(c2.T==1) ;
    
    for k=1:length(ind)
        min2(k,d2) = js2(ind(k),:); 
    end
    
    pv = intersect(d1,d2) ;
    
    n1 = size(min1,1) ;
    n2 = size(min2,1) ;
    a = 1 ;
    for k1=1:n1        
        for k2=1:n2
            if isempty(pv)
                min_states(a,d1) = min1(k1,d1) ; 
                min_states(a,d2) = min2(k2,d2) ;
                a = a + 1 ;
                consistency = 1 ;
            else if min1(k1,pv) == min2(k2,pv)
                    consistency = 1 ;
                    min_states(a,d1) = min1(k1,d1) ; 
                    min_states(a,d2) = min2(k2,d2) ;
                    a = a + 1 ;
                end
            end
        end
    end
    
    if (consistency == 0)
        error('States consistency problem'); 
        return ;
    end
    d1 = union(d1,d2); 
    min1 = min_states ;
    consistency = 0 ;
end

hidden = find(isemptycell(evidence)) ;
lpe.domain = hidden ;
lpe.states = min1(:,hidden) ;


                
   