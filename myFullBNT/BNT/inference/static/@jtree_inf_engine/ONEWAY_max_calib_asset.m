function maxAsset = ONEWAY_max_calib_asset(engine, asset, evidence)
% This is to find the maximum global value, by max-propagation. Because we
% do not need to know the configuration of joint state associated with the
% min value, we can do a one-way propagation instead of regular
% round-trip junction tree propagation.
% Aug.3, 2012
% -wsun

if nargin < 3, evidence = []; end

% Absorbing evidence into asset tables
% Given Assm=assm, and Targ=targ
observed = find(~isemptycell(evidence)) ;
if ~isempty(observed)    
    N = length(asset.clq) ;
    for k=1:N
        clq = asset.clq{k} ;
        domain = clq.domain ;    
        common = myintersect(domain, observed) ;    

        % Absorbing given conditions for cliques that involving
        % observed variables only
        if ~isempty(common)             
            asset.clq{k} = absorb_pot_obs(clq,common,evidence) ;
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
        end
    end
end


qclq= asset.clq ;
qsep = asset.sep ;

moption = 'max' ; %engine.maximize = 1; %to make sure to run max-calibration
for n=engine.postorder %postorder(1:end-1)
  for p=engine.postorder_parents{n}
    %qclq{p} = divide_by_pot(qclq{p}, qsep{p,n}); % qsep is not 1, so need to run the computation
    %seppot{p,n} = marginalize_pot(clpot{n}, engine.separator{p,n}, engine.maximize);
    %modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
    %-wsun
    qsep_new = marginalize_pot(qclq{n}, engine.separator{p,n}, moption);
    if ~isempty(mysetdiff(qsep_new.domain,qsep{p,n}.domain))
        error('Separator domains have to match');
    end
    qsep_gain = qsep_new ;
    if sum(size(qsep_new.T) - size(qsep{p,n}.T)) ~= 0
        qsep_new
        qsep{p,n}
        xxx = 33 
    end
    qsep_gain.T = qsep_new.T - qsep{p,n}.T ;  
    smallT = qsep_gain.T;
    smalldom = qsep_gain.domain;
    smallsz = qsep_gain.sizes;
    bigdom = qclq{p}.domain;
    bigsz = qclq{p}.sizes;
    Ts = extend_domain_table(smallT, smalldom, smallsz, bigdom, bigsz);
    assert(length(Ts(:))==length(qclq{p}.T(:))) ;
    temp_T = qclq{p}.T(:) + Ts(:) ;
    qclq{p}.T = reshape(temp_T, qclq{p}.sizes) ;
  end
end

maxAsset = max(qclq{n}.T(:)) ;
