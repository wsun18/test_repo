function cProb = find_marginal_from_pot_v2(engine, Targ, Assm, assm)
% This is to compute the marginal probability of one node each time

if nargin <= 2, Assm = {}; assm=[]; end

bnet = bnet_from_engine(engine) ; 
clpot = clpot_from_engine(engine) ;
TargInd = findindex4stringcell(bnet.node_names, Targ) ;
if isempty(Assm)
    c = clq_containing_nodes(engine, TargInd);
else
    AssmInd = [] ;
    for i=1:length(assm)
        AssmInd = [AssmInd findindex4stringcell(bnet.node_names, Assm{i})] ;
    end
    c = clq_containing_nodes(engine, [TargInd AssmInd]);
end
            
model.node_names = bnet.node_names(clpot{c}.domain) ;
model.sizes = bnet.node_sizes(clpot{c}.domain) ;

jp = clpot{c}.T(:) ;


cProb = bf_find_currProb(model,jp,Targ,Assm,assm) ;


