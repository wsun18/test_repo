function u_abc = updateUserAssetBlocks(u_abc,cProb,tProb,Targ,Assm,assm) 
% This is to update user's asset block (u_ab) for the particular trade on
% P(Targ=targ|Assm=assm) 
% 9/23/2013, wsun

global S b log_base vList vSizes ;

if nargin < 4, error('Number of arguments has to be at least 4'); end
if nargin < 5, Assm = {}; assm=[]; end


dom = [] ;

if ~isempty(Assm)
    indAssm = [] ;
    for k=1:length(Assm)
        indAssm = [indAssm findindex4stringcell(vList, Assm{k})] ;
    end
    %assm = reshape(assm,[1,length(assm)]) ;
    dom = sort(indAssm) ;
end
indTarg = findindex4stringcell(vList, Targ);

dom = sort([indTarg dom]) ;
var_names = vList(dom) ;
var_sizes = vSizes(dom) ;

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
    sortedIndAssm = sort(indAssm) ; 
    posAssm = [] ;
    for k=1:length(assm)
        posAssm = [posAssm find_equiv_posns(sortedIndAssm(k), dom)] ;
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
    
end

if ff==0 % for completely separate domain or partially intersected domain
    aBlock.T = aDelta ;
    
    u_abc{end+1} = aBlock ;
end




