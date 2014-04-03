% function dac = DAC_VP_updateUserAssetBlocks(dac,cProb,tProb,Targ, T_sz, Assm,assm, A_sz) 
% DAC model. This is to update user's dac for the particular trade on
% P(Targ=targ|Assm=assm) 
% We need to maintain dac.Q_list, dac.ns, dac.abc accordingly.
% dac.base should be no change.
% For each user registered, dac.base should be the least field assigned with initial value.
% 11/6/2013, wsun

%% rewrite DAC code for coping with VP-node (value partitioning node) 
%  -wsun, Feb.4, 2014, China.
function [dac, VP_Targ, VP_Assm] = DAC_VP_updateUserAssetBlocks(dac, VP_Targ, delta, targ_range, ref_range, Assm, assm, ...
    A_sz, VP_Assm, assm_range) 
%  
%  A VP-node has following attributes: 
%   (1) strname; (2) min; (3) max; (4) cutpoints, assuming cutpoints are
%   values between 'min' and 'max' (exclusive).
%   
%  Interface with GBS:
%
%       def add_hierarchial_assets_by_state(self, question_id, 
%           target_path_range, reference_path_range = None, 
%           assumption_dict = None, assets_by_state = None):
%
%  The new function has no probabilities in arguments, but only asset
%  change, and target question (VP) id, target_interval,
%  reference_interval, assumption_dict.
%  
%  Arguments in my Matlab function:
%      (dac, delta, VP_Targ, targ_range, ref_range, Assm, assm, VP_Assm,
%      VP_assm_range)
% 
%      delta:       the asset changes W1 (on target range) and W2 (on other 
%                   reference range excluding target).
%      VP_Targ:     the target VP-node.
%      targ_range:  target range.
%      ref_range:   reference range on target VP-node; default is the root.
%      Assm:        regular assumption question nodes.
%      assm:        assumed states for regular assumption questions.
%      A_sz:        node sizes for regular assumption questions.
%      VP_Assm:     VP assumption nodes.
%      assm_range:  assumed target range for VP assumption nodes. Orgnized
%                   in matrix representation, each row indicates the given
%                   range of the corresponding VP assumption question.
%                   Number of rows shall be equal to the number of the VP
%                   assumpotion questions.



%% code to update user asset blocks after a general trade on VP-node given assumption.

% global b log_base

if nargin < 4, error('Number of arguments has to be at least 4'); end
if nargin < 5, ref_range=[]; Assm={}; assm=[]; VP_Assm={}; assm_range=[]; end
if nargin < 6, Assm={}; assm=[]; VP_Assm={}; assm_range=[]; end
if nargin < 9, VP_Assm={}; assm_range=[]; end

%% Note: a new registered user will be assigned an initial asset model 
%  with the following: 
%     dac.base = S + addCash; dac.Obj_list = {}; dac.Q_list = {}; dac.ns = []; dac.abc={}; 
%     user.dac = dac ;
%  So any registered user has asset model with those attributes.


Obj_list = dac.Obj_list ; 
% Obj_list saves all questions in the form of being as objects, i.e., 
% a VP question is an object containing several fields.

Q_list = dac.Q_list ; % Q_list is the set saving basic names of all questions over all asset blocks.
ns = dac.ns ;
u_abc = dac.abc ;

%% update cutpoints for VP_Targ
VPTarg_old_cutpoints = VP_Targ.cutpoints ;   % save a copy of current cutpoints for VP_Targ

cutpoints = VP_Targ.cutpoints ;
if isempty(cutpoints)
    new_cutpoints = sort([targ_range, ref_range]) ;
else
    new_cutpoints = sort([cutpoints targ_range ref_range]) ;  
end
% clean cutpoint who is same as 'min' or 'max' of the VP-node
if new_cutpoints(1) == VP_Targ.min
    new_cutpoints(1) = [] ;
elseif new_cutpoints(end) == VP_Targ.max
    new_cutpoints(end) = [] ;
end
VP_Targ.cutpoints = new_cutpoints ;
% state_set = new_cutpoints ;
% state_set(end+1) = VP_Targ.max ;
T_sz = length(new_cutpoints) + 1 ;


% update cutpoints using 'assm_range' for VP assumption nodes. 
if ~isempty(VP_Assm)        
    assert(length(VP_Assm) == size(assm_range,1)) ;
    for k=1:length(VP_Assm)
        currVP_Assm = VP_Assm{k} ;
        cutpoints = currVP_Assm.cutpoints ;
        
        % save a copy of current cutpoints for VP_Assm. commented out due
        % to possible error. -wsun, 3/30/14
        % VPAssm_old_cutpoints(k,:) = cutpoints ; 
        
        if isempty(cutpoints)
            new_cutpoints = assm_range(k,:) ;
        else
            new_cutpoints = sort([cutpoints assm_range(k,:)]) ;
        end
        
        % clean cutpoint who is same as 'min' or 'max' of the VP-node
        if new_cutpoints(1) == currVP_Assm.min
            new_cutpoints(1) = [] ;
        elseif new_cutpoints(end) == currVP_Assm.max
            new_cutpoints(end) = [] ;
        end
        
        currVP_Assm.cutpoints = new_cutpoints ;
        VP_Assm{k} = currVP_Assm ;
        VP_A_sz(k) = length(new_cutpoints) + 1 ;
    end
end

%% update Obj_list, Q_list and ns (node size vector)
if isempty(Q_list)
    assert(isempty(ns)) ; 
    assert(isempty(u_abc)) ;
    assert(isempty(Obj_list)) ;
    
    Obj_list{end+1} = VP_Targ ;
    
    Q_list{end+1} = VP_Targ.strname ;
    ns(end+1) = T_sz ;
    for k=1:length(assm)
        Obj_list(end+1) = Assm(k) ;
        Q_list(end+1) = Assm(k) ;
        ns(end+1) = A_sz(k) ;
    end   
    if ~isempty(VP_Assm)
        for k=1:length(VP_Assm)
            Obj_list{end+1} = VP_Assm{k} ;
            Q_list{end+1} = VP_Assm{k}.strname ;
            ns(end+1) = VP_A_sz(k) ;
        end
    end        
else    
    if ~ismember(VP_Targ.strname, Q_list)
        Obj_list{end+1} = VP_Targ ;
        Q_list{end+1} = VP_Targ.strname ;
        ns(end+1) = T_sz ;
    else
        ns(findindex4stringcell(Q_list, VP_Targ.strname)) = T_sz ;
    end
    
    for k=1:length(assm)
        if ~ismember(Assm{k}, Q_list)
            Obj_list(end+1) = Assm(k) ;
            Q_list(end+1) = Assm(k) ;
            ns(end+1) = A_sz(k) ;
        end
    end
    
    for k=1:length(VP_Assm)
        if ~ismember(VP_Assm{k}.strname, Q_list)
            Obj_list{end+1} = VP_Assm{k} ;
            Q_list{end+1} = VP_Assm{k}.strname ;
            ns(end+1) = VP_A_sz(k) ;
        else
            ns(findindex4stringcell(Q_list, VP_Assm{k}.strname)) = VP_A_sz(k) ;
        end
    end
end

dac.Obj_list = Obj_list ;
dac.Q_list = Q_list ;
dac.ns = ns ;


%% decide the local domain for the asset block associated with the trade
dom = [] ;

if ~isempty(Assm)
    indAssm = zeros(1,length(Assm)) ;
    for k=1:length(Assm)
        indAssm(k) = findindex4stringcell(Q_list, Assm{k}) ;
    end
    assert(isequal(ns(indAssm),A_sz)) ;
    dom = sort(indAssm) ;
end

if ~isempty(VP_Assm)
    ind_VPAssm = zeros(1,length(VP_Assm)) ;
    for k=1:length(VP_Assm)
        ind_VPAssm(k) = findindex4stringcell(Q_list, VP_Assm{k}.strname) ;
    end
    assert(isequal(ns(ind_VPAssm),VP_A_sz)) ;
    dom = sort([dom ind_VPAssm]) ;
end
ind_VPTarg = findindex4stringcell(Q_list, VP_Targ.strname);

dom = sort([ind_VPTarg dom]) ; % local domain for this particular asset block.
var_names = Q_list(dom) ;
var_sizes = ns(dom) ;

assert(ns(ind_VPTarg) == T_sz) ;

aBlock.dom = dom ;
aBlock.var_names = var_names ;
aBlock.var_sizes = var_sizes ;
if length(var_sizes)>1
    aDelta = zeros(var_sizes) ;
else
    aDelta = zeros(var_sizes,1) ;
end

% aBlock.T: the asset table in this asset block.

h_cc = full_combination_new(var_sizes) ;
noi = size(h_cc,1); % number of instances

posTarg = find_equiv_posns(ind_VPTarg, dom) ;

if ~isempty(Assm)    
    posAssm = zeros(1,length(Assm)) ;
    for k=1:length(assm)
        posAssm(k) = find_equiv_posns(indAssm(k), dom) ;
    end
end

if ~isempty(VP_Assm)    
    pos_VPAssm = zeros(1,length(VP_Assm)) ;
    for k=1:length(VP_Assm)
        pos_VPAssm(k) = find_equiv_posns(ind_VPAssm(k), dom) ;
    end
end


% assigning 'delta' to the appropriate cells in the asset table 'aDelta'
% case 1: flat trade
if isempty(Assm) && isempty(VP_Assm)
    for i=1:noi
        instance = h_cc(i,:) ;
        targ_state = instance(posTarg) ;      
        aDelta(i) = DAC_VP_assign_w1w2_to_cell(VP_Targ,targ_state,delta,targ_range,ref_range) ;
    end
end 

% case 2: combo trade given regular assumption questions only
if ~isempty(Assm) && isempty(VP_Assm)
    for i=1:noi
        instance = h_cc(i,:) ;
        
        if isequal(instance(posAssm),assm)
            targ_state = instance(posTarg) ;
            aDelta(i) = DAC_VP_assign_w1w2_to_cell(VP_Targ,targ_state,delta,targ_range,ref_range) ;
        end
    end
end


% case 3: combo trade given VP assumption questions only
if isempty(Assm) && ~isempty(VP_Assm)
    for i=1:noi
        instance = h_cc(i,:) ;
        vpassm_state = instance(pos_VPAssm) ; 
        vpassm_state_range = DAC_VP_transfer_state_to_range(VP_Assm, vpassm_state) ;

        if DAC_mysubintval(vpassm_state_range, assm_range) 
            targ_state = instance(posTarg) ;
            aDelta(i) = DAC_VP_assign_w1w2_to_cell(VP_Targ,targ_state,delta,targ_range,ref_range) ;
        end 
    end
end

% case 4: combo trade given both regular and VP assumption questions 
if ~isempty(Assm) && ~isempty(VP_Assm)
    for i=1:noi
        instance = h_cc(i,:) ;
        vpassm_state = instance(pos_VPAssm) ; 
        vpassm_state_range = DAC_VP_transfer_state_to_range(VP_Assm, vpassm_state) ;

        if DAC_mysubintval(vpassm_state_range, assm_range) && isequal(instance(posAssm),assm)
            targ_state = instance(posTarg) ;
            aDelta(i) = DAC_VP_assign_w1w2_to_cell(VP_Targ,targ_state,delta,targ_range,ref_range) ;
        end 
    end
end


if isempty(u_abc)  
    aBlock.T = aDelta ;
    u_abc{1} = aBlock ;
    dac.abc = u_abc ;
    return ;
end




%% update current existing asset blocks that contain 'VP_Targ' or 'VP_Assm'
%  to matach potentially new cutpoints.
for i=1:length(u_abc)
    curr_ab = u_abc{i} ; % fieldnames: dom, var_names, var_sizes, T
    Nm = curr_ab.var_names ;
   
    if ismember(VP_Targ.strname, Nm)
        curr_ab = DAC_VP_update_block_by_new_cutpoints(curr_ab, ind_VPTarg,...
            VPTarg_old_cutpoints, VP_Targ.cutpoints) ; 
        u_abc{i} = curr_ab ;
    end
    
    if ~isempty(VP_Assm)
        for k=1:length(VP_Assm)
            c_VP = VP_Assm{k} ;
            if ismember(c_VP.strname, Nm)
                c_old_cutpoints = VPAssm_old_cutpoints(k,:) ;
                c_ind_VP = ind_VPAssm(k) ;
                curr_ab = DAC_VP_update_block_by_new_cutpoints(curr_ab, ...
                    c_ind_VP, c_old_cutpoints, c_VP.cutpoints) ;
            end            
        end
    end
end


%% three scenarios if user asset block is not empty
%  1. completely same domain;
%  2. sub-domain of existing block;
%  3. super-domain of existing block;
%  4. completely separate domain;
%  5. partially intersected. part of domain are new, while others are
%  common.
ff = 0 ;
for i=1:length(u_abc)
    curr_ab = u_abc{i} ;
    Nm = curr_ab.var_names ;
    c_dom = curr_ab.dom ;
        
    if isempty(setdiff(Nm,var_names)) && isempty(setdiff(var_names,Nm)) % exactly same domain
        u_abc{i}.T = u_abc{i}.T + aDelta ;
        ff = 1 ;
    elseif mysubset(dom, c_dom) % sub-domain of existing block
        smallT = aDelta ;
        smalldom = dom ;
        smallsz = var_sizes ;
        bigdom = c_dom ;
        bigsz = curr_ab.var_sizes ;
        Ts = extend_domain_table(smallT, smalldom, smallsz, bigdom, bigsz);
        curr_ab.T = curr_ab.T + Ts ;
        
        u_abc{i} = curr_ab ;
        
        ff = 1 ;
    elseif mysubset(c_dom, dom) % super-domain of existing block
        smallT = curr_ab.T ;
        smalldom = c_dom ;
        smallsz = curr_ab.var_sizes ;
        bigdom = dom ;
        bigsz = var_sizes ;
        Ts = extend_domain_table(smallT, smalldom, smallsz, bigdom, bigsz);
        aDelta = aDelta + Ts ;
        aBlock.T = aDelta ;
        
        u_abc{i} = aBlock ;
        
        ff = 1 ;
    end 
    
    if ff==1 % only need to merge to exactly one of existing block
        break ;
    end
end

%%% iteration#96 in our Y2 cross test suite 1186 exposed a very interesting
%%% phenomeon where user u3 has 4 asset blocks before the trade.
%%% Respectively, they have domains as [1, 2], [3,4], [4, 5], and [2, 6].
%%% But the trade is (1|2,6), which brought the original block#1 and
%%% block#4 to have exactly same domain after merging trade individually.
%%% What the coincidence!!. And this immediately raised up the need to
%%% recheck all blocks after merging trade, to see if there are any blocks
%%% need to be merged again. :) -wsun, 11/6/2013
del_ind = [] ;
for i=1:length(u_abc)
    i_dom = u_abc{i}.dom ;
    for j=i+1:length(u_abc)
        j_dom = u_abc{j}.dom ;
        
        if mysubset(i_dom, j_dom)
%             assert(isequal(u_abc{i}.var_sizes, u_abc{j}.var_sizes)) ;
%             assert(sum(strcmp(u_abc{i}.var_names, u_abc{j}.var_names))==length(u_abc{i}.var_names)) ;

            smalldom = i_dom ;
            smallsz = u_abc{i}.var_sizes ;
            smallT = u_abc{i}.T ;
            bigdom = u_abc{j}.dom ;
            bigsz = u_abc{j}.var_sizes ;
            Ts = extend_domain_table(smallT, smalldom, smallsz, bigdom, bigsz); 
            u_abc{j}.T = u_abc{j}.T + Ts ;            
            del_ind(end+1) = i ; 
            
        elseif mysubset(j_dom, i_dom) 
            smalldom = j_dom ;
            smallsz = u_abc{j}.var_sizes ;
            smallT = u_abc{j}.T ;
            bigdom = u_abc{i}.dom ;
            bigsz = u_abc{i}.var_sizes ;
            Ts = extend_domain_table(smallT, smalldom, smallsz, bigdom, bigsz); 
            u_abc{i}.T = u_abc{i}.T + Ts ;            
            del_ind(end+1) = j ; 
            
        end        
    end
end
u_abc(del_ind) = [] ; % delete the redundant elements.

% Solution 1 failed because the blocks already merged more than once before
% you adjust. I nned to prevent merge more than once in the previous ff for
% loop. ff should be used smartly as the flag.


if ff==0 % for completely separate domain or partially intersected domain
    aBlock.T = aDelta ;
    
    u_abc{end+1} = aBlock ;
end

dac.abc = u_abc ;



