function [engine asset_part] = POT_ASSET_update_cash(engine,clpot,asset,cid,old_T,new_T,userType)
% This function is supposed to update all potentials and asset for the
% changes made on clpot only.
% -wsun, 5/7/2013

if nargin < 7, userType=[]; end

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

% clpot{1}.T
% clpot{2}.T


pc_ratio{cid} = new_T ./ old_T ;

asset_part = asset ;
b = asset.b ;
log_base = asset.logbase ;
switch(log_base)
    case 2
        assetT = (asset.clq{cid}.T) + b*log2(pc_ratio{cid}) ; 
        negInd = find(assetT<0) ;
        if ~isempty(negInd) 
            if strcmp(userType,'Noiser')
                fprintf('Noiser ran into negative asset, press any key to add bonus \n') ;
                assetT
                pause
                assetT = assetT - min(assetT(:)) + 200000 ;
            end            
%             if max(0 - assetT(negInd)) < .0005
%                 assetT(negInd) = 0 ;
%             else
%                 fprintf('POT_ASSET_update.m : Negative asset occurred \n') ;
%                 assetT = assetT - min(assetT) + 50 ;
%                 pause
%             end
        end
        asset_part.clq{cid}.T = assetT ;        
        asset_part.global_min = ONEWAY_min_calib_asset(engine,asset_part) ;
        localmin = min(assetT(:)) ;
        assetT = assetT - localmin ;
        asset_part.clq{cid}.T = assetT ;
        asset_part.cash = asset_part.cash + localmin ;  
        assert(asset_part.cash <= asset_part.global_min) ;
    case exp(1)
        assetT = (asset.clq{cid}.T) + b*log(pc_ratio{cid}) ;   
        assert(isempty(find(assetT<0))) ;
        asset_part.clq{cid}.T = assetT ;
    otherwise
        error('Please specify log base value');
end


