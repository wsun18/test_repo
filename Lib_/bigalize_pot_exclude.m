function pot = bigalize_pot_exclude(pot,exclude,es)
% bigalize_pot_exclude is to update the potential table by making the 
% elements corresponding to exclude variable at 'es' state to be big number
% greater than any other elements.

domain = pot.domain ;
T = pot.T ;
sz = pot.sizes ;

M = max(T(:)) ;

if myintersect(domain(1),exclude)    
    indmat = es ;
    T(es,:) = M + 1 ;
    pot.T = T; 
    return ;
else
    indmat = 1:sz(1) ;
    indmat = indmat' ;
end

for i=2:length(domain)            
    if myintersect(domain(i),exclude)        
        indmat(:,end+1) = es; 
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
    T(pos) = M + 1;     
end
pot.T = T;

