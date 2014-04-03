function minAsset = ONEWAY_min_calib_asset_exclude(engine, asset, evidence, exclude, es)
% This is to find the LPE by running min-calibration for a compiled
% network, namely, we already have normalized clique potentials (which is
% actually joint probability distributions for all cliques).
% The argument 'engine' has compiled 'clpot' and 'seppot' saved
% inside, that are results provided by regular sum-product Junction tree
% algorithm.
% Dec.5, 2011
% -wsun

% when there is a single variable we need to exclude its one single state
% from consideration, we make the corresponding elements associated with
% that particular state very big, and so they will not be chosen in the
% process of min-propagation. -wsun, 3/7/12


% Absorbing evidence into asset tables
% Given Assm=assm, and Targ~=targ
observed = find(~isemptycell(evidence)) ;
N = length(asset.clq) ;
tp_asset = asset ;
for k=1:N
    clq = asset.clq{k} ;
    domain = clq.domain ;    
    common = myintersect(domain, observed) ;   
                 
    % Absorbing given conditions for cliques that involving
    % observed variables only
    if ~isempty(common)             
        asset.clq{k} = absorb_pot_obs(clq,common,evidence) ;
        tp_asset.clq{k} = absorb_pot_obs(clq,common,evidence) ;        
    end
    % replacing elements corresponding Targ=targ with big number
    if ~isempty(myintersect(domain, exclude))
        tp_asset.clq{k} = bigalize_pot_exclude(asset.clq{k},exclude,es) ;        
    end
end

          
sepmeat = find(~cellfun('isempty',asset.sep)==1) ;
n = length(sepmeat) ;
for k=1:n
    sep = asset.sep{sepmeat(k)} ;
    domain = sep.domain ;    
    common = myintersect(domain, observed) ;    
             
    % Absorbing given conditions for cliques that involving
    % observed variables only
    if ~isempty(common)             
        asset.sep{sepmeat(k)} = absorb_pot_obs(sep,common,evidence) ;
        tp_asset.sep{sepmeat(k)} = absorb_pot_obs(sep,common,evidence) ;
    end
    % replacing elements corresponding Targ=targ with big number
    if ~isempty(myintersect(domain, exclude))
        tp_asset.sep{sepmeat(k)} = bigalize_pot_exclude(asset.sep{sepmeat(k)},exclude,es) ;        
    end
end


qclq= tp_asset.clq ;
qsep = tp_asset.sep ;

moption = 'min' ;
for n=engine.postorder %postorder(1:end-1)
  for p=engine.postorder_parents{n}
    qsep_new = marginalize_pot(qclq{n}, engine.separator{p,n}, moption);
    if ~isempty(mysetdiff(qsep_new.domain,qsep{p,n}.domain))
        error('Separator domains have to match');
    end
    qsep_gain = qsep_new ;
    qsep_gain.T = qsep_new.T(:) - qsep{p,n}.T(:) ;  
    smallT = qsep_gain.T;
    smalldom = qsep_gain.domain;
    smallsz = qsep_gain.sizes;    
    bigdom = qclq{p}.domain;
    bigsz = qclq{p}.sizes;
    Ts = extend_domain_table(smallT, smalldom, smallsz, bigdom, bigsz);
    bigT = reshape(qclq{p}.T, bigsz) ;    
    qclq{p}.T = bigT + Ts ;
  end
end

minAsset = min(qclq{n}.T(:)) ;
