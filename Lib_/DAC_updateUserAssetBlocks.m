function dac = DAC_updateUserAssetBlocks(dac,cProb,tProb,Targ, T_sz, Assm,assm, A_sz) 
% Rewriting DAC model. This is to update user's dac for the particular trade on
% P(Targ=targ|Assm=assm) 
% We need to maintain dac.Q_list, dac.ns, dac.abc accordingly.
% dac.base should be no change.
% For each user registered, dac.base should be the least field assigned with initial value.
% 11/6/2013, wsun

global b log_base

if nargin < 4, error('Number of arguments has to be at least 4'); end
if nargin < 5, Assm = {}; assm=[]; end

Q_list = dac.Q_list ;
ns = dac.ns ;
u_abc = dac.abc ;


%% update Q_list first
if isempty(Q_list)
    assert(isempty(ns)) ; 
    assert(isempty(u_abc)) ;
    
    Q_list(end+1) = Targ ;
    ns(end+1) = T_sz ;
    for k=1:length(assm)
        Q_list(end+1) = Assm(k) ;
        ns(end+1) = A_sz(k) ;
    end    
else    
    if ~ismember(Targ, Q_list)
        Q_list(end+1) = Targ ;
        ns(end+1) = T_sz ;
    end
    
    for k=1:length(assm)
        if ~ismember(Assm{k}, Q_list)
            Q_list(end+1) = Assm(k) ;
            ns(end+1) = A_sz(k) ;
        end
    end
end

dac.Q_list = Q_list ;
dac.ns = ns ;


%% decide the local domain for the asset block associated with the trade
dom = [] ;

if ~isempty(Assm)
    indAssm = [] ;
    for k=1:length(Assm)
        indAssm = [indAssm findindex4stringcell(Q_list, Assm{k})] ;
    end
    assert(isequal(ns(indAssm),A_sz)) ;
    dom = sort(indAssm) ;
end
indTarg = findindex4stringcell(Q_list, Targ);

dom = sort([indTarg dom]) ; % local domain for this particular asset block.
var_names = Q_list(dom) ;
var_sizes = ns(dom) ;


assert(ns(indTarg) == T_sz) ;


aBlock.dom = dom ;
aBlock.var_names = var_names ;
aBlock.var_sizes = var_sizes ;
if length(var_sizes)>1
    aDelta = zeros(var_sizes) ;
else
    aDelta = zeros(var_sizes,1) ;
end

% aBlock.T ;

h_cc = full_combination_new(var_sizes) ;
noi = size(h_cc,1); % number of instances

posTarg = find_equiv_posns(indTarg, dom) ;

if ~isempty(Assm)    
    posAssm = [] ;
    for k=1:length(assm)
        posAssm = [posAssm find_equiv_posns(indAssm(k), dom)] ;
    end
end
% calculate the asset change
for i=1:noi
    instance = h_cc(i,:);   
    if ~isempty(Assm)
        if isequal(instance(posAssm),assm)
            targ_state = instance(posTarg) ;
            aDelta(i) = b*logb(tProb(targ_state)/cProb(targ_state),log_base) ;
        end
    else
        targ_state = instance(posTarg) ;       
        aDelta(i) = b*logb(tProb(targ_state)/cProb(targ_state),log_base) ;
    end   
end
% if leng(var_names)>1
%     aDelta = reshape(aDelta,var_sizes) ;
% else
%     aDelta = reshape(aDelta,[var_sizes 1]) ;
% end


if isempty(u_abc)  
    aBlock.T = aDelta ;
    u_abc{1} = aBlock ;
    dac.abc = u_abc ;
    return ;
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



