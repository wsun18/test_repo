function pot = absorb_pot_obs(pot,obv,evidence)
% absorb_pot_obs is to update the potential table by absorbing the 
% observed variables with its observed values. Namely, extract
% the right elements from the original potential table.
% obv is the observed variables; obs is the corresponding observed values.

%if nargin <= 3, Exclude = []; es=[]; end

domain = pot.domain ;
T = pot.T ;
sz = pot.sizes ;

new_sz = sz ;
for j=1:length(obv)
    ii(j) = find(domain==obv(j)) ;
end
new_sz(ii) = 1 ;
real_dom = domain(find(new_sz>1)) ;
real_sz = new_sz(find(new_sz>1)) ;

if myintersect(domain(1),obv)
    obs = evidence{domain(1)} ;
    indmat = obs ;
else
    indmat = 1:sz(1) ;
    indmat = indmat' ;
end

for i=2:length(domain)            
    if myintersect(domain(i),obv)
        obs = evidence{domain(i)} ;
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

% -wsun, 9/11/2013, due to the size issue, I corrected it to be matching
% the new size after absorbing evidence.
if length(new_sz) > 1
    newT = reshape(newT, new_sz) ;
end

pot.T = newT;
pot.sizes = new_sz ;
