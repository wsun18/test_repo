
function ab = updateAssetBlock_Resolving(ab, resDom, resObs)
% This is to update a particular asset block when resolving questions involved in the
% asset block. 
% ab is the asset block which needs to be updated by resolving questions.
% ab is a struct has four fields: (1)dom; (2)var_names; (3)var_sizes; (4)T

% resDom is the resolving question domain, which has to be a subset of
% block's domain.
% resObs is the resolved states of the resolving questions. 
% -wsun, 10/12/2013.

domain = ab.dom;
T = ab.T ;
sz = ab.var_sizes ;

new_sz = sz ;
posRes = [] ;
for k=1:length(resDom)
    posRes = [posRes find_equiv_posns(resDom(k), domain)] ;
end
new_sz(posRes) = 1 ;
real_dom = domain(find(new_sz>1)) ;
real_sz = new_sz(find(new_sz>1)) ;

posRealDom = []; 
for k=1:length(real_dom)
    posRealDom = [posRealDom find_equiv_posns(real_dom(k), domain)] ;
end
real_var_names = ab.var_names(posRealDom) ;

if myintersect(domain(1),resDom)
    posRes = find_equiv_posns(domain(1), resDom) ;
    obs = resObs(posRes) ;
    indmat = obs ;
else
    indmat = 1:sz(1) ;
    indmat = indmat' ;
end

for i=2:length(domain)            
    if myintersect(domain(i),resDom)
        posRes = find_equiv_posns(domain(i), resDom) ;
        obs = resObs(posRes) ;
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
    newT(a) = T(pos);     
end

% -wsun, 11/2/2013, if we resolve all variables in this block, then it
% degrades to a scalar number.
if isempty(real_dom)
    ab = newT ;
    return ;
end


% -wsun, 9/11/2013, due to the size issue, I corrected it to be matching
% the new size after absorbing the settled question.
if length(real_sz) > 1
    newT = reshape(newT, real_sz) ;
else
    newT = reshape(newT, [real_sz 1]) ;
end

ab.dom = real_dom ;
ab.T = newT;
ab.var_sizes = real_sz ;
ab.var_names = real_var_names ;