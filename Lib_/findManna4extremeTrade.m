function [asset manna] = findManna4extremeTrade(engine, asset, extprob, Targ, targ, Assm, assm) 

if nargin < 5, error('It has to have at least 4 arguments'); end
if nargin < 6, Assm = {}; assm=[]; end

bnet = bnet_from_engine(engine) ;
N = length(bnet.dag) ;

% Given events, find the min-global-state from local tables by min-propagation
% Given Assm=assm, and Targ=targ
evids = cell(1,N) ;
for k=1:length(assm)
    indassm(k) = findindex4stringcell(bnet.node_names, Assm{k}) ;
    evids{indassm(k)} = assm(k) ;
end
indtarg = findindex4stringcell(bnet.node_names, Targ) ;
evids{indtarg} = targ ;
observed = find(~isemptycell(evids)) ;
minAsset1 = ONEWAY_min_calib_asset(engine, asset, evids) ;


b = asset.b ;
log_base = asset.logbase ;
% % from updated clpot and seppot, calculate the correct marginal given
% % evidence
evids{indtarg} = [] ; % retract evidence on 'Targ' node
margTarg = marginal_nodes_from_pot(engine, indtarg, evids);
cprob = margTarg.T(targ) ;

lbd = cprob * log_base^(-minAsset1/b) ;  % lower edit bound

if extprob < lbd
    mat1 = logb(extprob/cprob, log_base) * b * (-1) ;
    manna = mat1 - minAsset1 ;
    manna = manna + 300000 ;
    
    for k=1:length(asset.clq) 
        asset.clq{k}.T = asset.clq{k}.T + manna ; % initialize S to be 1000 for every cell in the clique 
    end
    sepmeat = find(~cellfun('isempty',asset.sep)==1) ;
    for k=1:length(sepmeat)
        fillin = sepmeat(k) ;
        asset.sep{fillin}.T = asset.sep{fillin}.T + manna ;
    end
    
    return ;

end

minAsset2 = ONEWAY_min_calib_asset_exclude(engine, asset, evids, indtarg, targ) ;
ubd = 1 - (1-cprob) * log_base^(-minAsset2/b) ; % upper edit bound

if extprob > ubd
    mat2 = logb((1-extprob)/(1-cprob), log_base) * b * (-1) ;
    manna = mat2 - minAsset2 ;
    manna = manna + 300000 ;
    
    for k=1:length(asset.clq) 
        asset.clq{k}.T = asset.clq{k}.T + manna ; % initialize S to be 1000 for every cell in the clique 
    end
    sepmeat = find(~cellfun('isempty',asset.sep)==1) ;
    for k=1:length(sepmeat)
        fillin = sepmeat(k) ;
        asset.sep{fillin}.T = asset.sep{fillin}.T + manna ;
    end
    
    return ;

end

manna = 0 ;


