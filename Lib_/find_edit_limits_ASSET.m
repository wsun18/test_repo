function [lbd ubd minq1 minq2] = find_edit_limits_ASSET(engine, asset, Targ, targ, Assm, assm) ;

if nargin < 4, error('It has to have at least 4 arguments'); end
if nargin < 5, Assm = {}; assm=[]; end

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


% minst_cell = num2cell(minq1.states) ;
% for j=1:size(minst_cell,1)
%     evids(minq1.domain) = minst_cell(j,:) ;
%     jst(j,:) = cell2num(evids) ;
% end

% Given Assm=assm, but Targ~=targ. My idea is to make it conditioning on 
% Assm=assm only, and for cases in which Targ=targ, I make the
% corresponding elements artificially huge number, so it will not be chosen
% when running min-propagation
% evids = cell(1,N) ;
% for k=1:length(assm)
%     indassm(k) = findindex4stringcell(bnet.node_names, Assm{k}) ;
%     evids{indassm(k)} = assm(k) ;
% end
% indtarg = findindex4stringcell(bnet.node_names, Targ) ;
evids{indtarg} = [] ; % retract evidence on 'Targ' node
minAsset2 = ONEWAY_min_calib_asset_exclude(engine, asset, evids, indtarg, targ) ;


% % from updated clpot and seppot, calculate the correct marginal given
% % evidence
margTarg = marginal_nodes_from_pot(engine, indtarg, evids);
% engine = enter_evidence(engine, evids) ;
% margTarg = marginal_nodes(engine, indtarg) ;

% for asset directly, 9/11/12,wsun
b = asset.b ;
log_base = asset.logbase ;
lbd = margTarg.T(targ) * log_base^(-minAsset1/b) ;     % lower edit bound
ubd = 1 - (1-margTarg.T(targ)) * log_base^(-minAsset2/b) ; % upper edit bound
