function minq = min_calib_asset_exclude(engine, asset, evidence, exclude, es)
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
        tp_asset.sep{k} = bigalize_pot_exclude(asset.sep{sepmeat(k)},exclude,es) ;        
    end
end


qclq= tp_asset.clq ;
qsep = tp_asset.sep ;

% engine.minimize = 1; %to make sure to run min-calibration
% [qclq_mincal, qsep_mincal] = collect_evidence(engine, qclq, qsep);
moption = 'min' ;
for n=engine.postorder %postorder(1:end-1)
  for p=engine.postorder_parents{n}
    qclq{p} = divide_by_pot(qclq{p}, qsep{p,n}); % qsep is not 1, so need to run the computation
    %seppot{p,n} = marginalize_pot(clpot{n}, engine.separator{p,n}, engine.maximize);
    %modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
    %-wsun
    qsep{p,n} = marginalize_pot(qclq{n}, engine.separator{p,n}, moption);
    qclq{p} = multiply_by_pot(qclq{p}, qsep{p,n});
  end
end
qclq_mincal = qclq ; qsep_mincal = qsep ;
[qclq_mincal, qsep_mincal] = distribute_evidence(engine, qclq_mincal, qsep_mincal);

% min-normalization
nc = length(qclq_mincal) ;
qclq_min_norm = qclq_mincal ;
for i=1:nc
    qclq_min_norm{i}.T = qclq_mincal{i}.T / min(qclq_mincal{i}.T(:)) ;
end

minq = find_lpe_sun(qclq_min_norm, evidence) ; %return min-states for hidden variables only

js(:,minq.domain) = minq.states ;
if ~isempty(observed)
    js(:,observed) = repmat(cell2num(evidence(observed)), size(minq.states,1),1) ;
end

for j=1:size(minq.states,1)   
   temp_q(j) = calc_joint_from_clsep(asset.clq, asset.sep, js(j,:)) ;
end

bb = temp_q(1) ;
nminstate = length(temp_q) ;
if nminstate > 1
    for j=2:nminstate
        if temp_q(j) ~= bb
            error('min-q value should be unique') ;
        end
    end
end
    
minq.q = bb ;



           
