function bar_score = calc_bar_score_ASSET(engine, asset, Targ, targ, Assm, assm)

% calc_bar_score is to calculate the expected score given assumptions. 
% engine has to be updated with non-evidence
% asset has to be the complete one without any given conditions

% Expected score given events, means that, the events we are conditioning
% on are assumed to be true, so their probabilities is set up to be 1,
% probabilities on other states will be adjusted accordingly. 
% We do not have to touch asset tables at all in order to calculate the
% expected score.

% An extremely simple example to illustrate the point: One single variable
% V, P(v) = 0.3, P(not v) = 0.7. Suppose the asset table is [80,110]. We
% know the expected score given no event is 80*0.3+110*0.7=101. But the
% expected score for V=v, is 80! This is equivalent to setting up P(V) = [1
% 0], then still multiplying P(V) with Asset(V).  -wsun, 3/12/2012.

if nargin < 2, error('It has to have at least two arguments'); end
if nargin < 3, Targ={}; targ=[]; Assm = {}; assm=[]; end
if nargin < 5, Assm = {}; assm=[]; end

% bnet = bnet_from_engine(engine) ;
% evids = cell(1,length(bnet.dag)) ;
% 
% engine = enter_evidence(engine,evids) ; % make sure engine is updated by empty evidence set.


bnet = bnet_from_engine(engine) ;
N = length(bnet.dag) ;

% Given events, extract the corresponding elements from asset tables.
% Given Assm=assm, and Targ=targ
evids = cell(1,N) ;
if ~isempty(Assm)
    for k=1:length(assm)
        indassm(k) = findindex4stringcell(bnet.node_names, Assm{k}) ;
        evids{indassm(k)} = assm(k) ;
    end
end
if ~isempty(Targ)
    indtarg = findindex4stringcell(bnet.node_names, Targ) ;
    evids{indtarg} = targ ;
end
observed = find(~isemptycell(evids)) ;
if ~isempty(observed)
    engine = enter_evidence(engine,evids) ;    
end
clpot = clpot_from_engine(engine) ;
seppot = seppot_from_engine(engine) ;

% if ~isempty(observed)
%     if isempty(exclude)    
%         [clpot seppot] = realize_pot(clpot, seppot, evids) ;
%     else
%         [clpot seppot] = realize_pot_exclude(clpot, seppot, evids,exclude) ;
%     end
% end
% if ~isempty(observed)
%     [clpot seppot] = realize_pot(clpot, seppot, evids) ;    
% end

% calculate bar_score=sum(clqpot * q-clq-table) - sum(seppot * q-sep-table)

bar_score = 0 ;
for k=1:length(clpot)
    pot = clpot{k} ;
    qtab = asset.clq{k} ;
    dom1 = pot.domain ;    
    dom2 = qtab.domain ; 
    if ~isequal(dom1,dom2)
        error('potential domain must be consistent with q-table domain') ; 
    end      
    
    common = myintersect(dom2,observed) ;
    %% try to extract right elements from right q-table
    if ~isempty(common)
        qtab = absorb_pot_obs(qtab,common,evids) ;
    end
   
    sz1 = pot.sizes ;
    sz2 = qtab.sizes ;
    if ~isequal(sz1,sz2)
        error('potential size must be consistent with q-table size') ; 
    end    
    
    T1 = pot.T ;
    %%T2 = b*log(qtab.T) ;
    T2 = qtab.T ;
    
    ttab = T1(:) .* T2(:) ;
    bar_score = bar_score + sum(ttab(:)) ;
end

sepmeat = find(~cellfun('isempty',seppot)==1) ;
for k=1:length(sepmeat)
    fillin = sepmeat(k) ;
    probsep = seppot{fillin} ; 
    assetsep = asset.sep{fillin}; 
    dom1 = probsep.domain ;    
    dom2 = assetsep.domain ;
    if ~isequal(dom1,dom2)
        error('potential domain must be consistent with q-table domain') ; 
    end       
    
    common = myintersect(dom2,observed) ;
    if ~isempty(common)
        assetsep = absorb_pot_obs(assetsep,common,evids) ;
    end
   
    sz1 = probsep.sizes ;
    sz2 = assetsep.sizes ;
    if ~isequal(sz1,sz2)
        error('potential size must be consistent with q-table size') ; 
    end
    
    T1 = probsep.T ;
    T2 = assetsep.T ;
    
    ttab = T1(:) .* T2(:) ;
    bar_score = bar_score - sum(ttab(:)) ;
end     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function [clpot seppot] = realize_pot(clpot,seppot,evids)
% 
% observed = find(~isemptycell(evids)) ;
% nc = length(clpot) ;
% for k=1:nc
%     clq = clpot{k} ;
%     domain = clq.domain ;    
%     common = myintersect(domain, observed) ;    
% 
%     % Absorbing given conditions for cliques that involving
%     % observed variables only
%     if ~isempty(common)             
%         clpot{k} = realize_pot_obs(clq,common,evids) ;
%     end
% end
% 
% sepmeat = find(~cellfun('isempty',seppot)==1) ;
% ns = length(sepmeat) ;
% for k=1:ns
%     sep = seppot{sepmeat(k)} ;
%     domain = sep.domain ;    
%     common = myintersect(domain, observed) ;    
% 
%     % Absorbing given conditions for cliques that involving
%     % observed variables only
%     if ~isempty(common)             
%         seppot{sepmeat(k)} = realize_pot_obs(sep,common,evids) ;
%     end
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function pot = realize_pot_obs(pot,obv,evidence)
% 
% domain = pot.domain ;
% T = pot.T ;
% sz = pot.sizes ;
% 
% for j=1:length(obv)
%     ii(j) = find(domain==obv(j)) ;
% end
% 
% hcc = full_combination_new(sz) ;
% for j=1:size(hcc,1) 
%     instance = hcc(j,:) ;
%     if ~isequal(instance(ii), cell2num(evidence(obv)))
%         pos = find_linearIndex_from_mat(sz,instance);       
%         T(pos) = 0 ;
%     end
% end
% 
% % Normalize the table again
% T = T / sum(T(:)) ;
% pot.T = T ;









