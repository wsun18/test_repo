function P_Targ = calc_conditionalDist_from_joint(x,TargId,AssmId,assm) 
% Calculate conditional probability P(Targ|Assm=assm) from the joint
% distribution
% - wsun, 4/12/2012

nov = ndims(x) ;
ns = size(x) ;
fdom = sort([TargId AssmId]) ;
sumover = mysetdiff(1:nov,fdom) ;

for k=sumover
    x = sum(x,k) ;
end


% function pot = absorb_pot_obs(pot,obv,evidence)
% % absorb_pot_obs is to update the potential table by absorbing the 
% % observed variables with its observed values. Namely, extract
% % the right elements from the original potential table.
% % obv is the observed variables; obs is the corresponding observed values.
% 
% if nargin <= 3, Exclude = []; es=[]; end

% domain = pot.domain ;
% T = pot.T ;


sz = ns(fdom) ;
new_sz = sz ;
for j=1:length(assm)
    ii(j) = find(fdom==AssmId(j)) ;
end
new_sz(ii) = 1 ;
real_dom = fdom(find(new_sz>1)) ;
real_sz = new_sz(find(new_sz>1)) ;

a1 = find(AssmId==fdom(1)) ;
if a1
    obs = assm(a1) ;
    indmat = obs ;
else
    indmat = 1:sz(1) ;
    indmat = indmat' ;
end

for i=2:length(fdom)   
    ai = find(AssmId==fdom(i)) ;
    if ai
        obs = assm(ai) ;
        indmat(:,end+1) = obs; 
    else
        tm{1} = indmat ;
        tm{1}(:,end+1) = 1 ;       
        tpind = tm{1} ;
        for j=2:sz(i)
           tm{j} = indmat ; 
           tm{j}(:,end+1) = j ;
           tpind = [tpind; tm{j}] ;
        end
        indmat = tpind ;   
    end
end   

for a=1:size(indmat,1)
    pos = find_linearIndex_from_mat(sz,indmat(a,:));
    newT(a) = x(pos);     
end
if ~isempty(real_sz)
    if length(real_sz)>1
        newT = reshape(newT, real_sz);
    else
        newT = reshape(newT, [real_sz 1]) ;
    end
end


newT = newT/sum(newT) ;

P_Targ = newT ;


