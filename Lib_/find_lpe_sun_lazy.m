function lpe = find_lpe_sun_lazy(clpot, evidence)
% Lazy version of finding LPE jointly from clques potentials after
% min-calibration.
% Since for big model, there are sometimes a huge number of min-states,
% they all have the same min-q value, this lazy version just to find one
% min-state, which is enough for computational purposes.
% March 28, 2012
% -wsun

%clpot = engine.clpot ;
nc = length(clpot) ;

%bnet = bnet_from_engine(engine);
%N = length(bnet.dag);
%min_states = zeros(1,N) ;

c1 = clpot{1} ;
d1 = c1.domain ;
js1 = full_combination_new(c1.sizes) ;
ind = find(c1.T==1) ;
% for k=1:length(ind)
%     min1(k,d1) = js1(ind(k),:); 
% end
min1(1,d1) = js1(ind(1),:) ;
min_states = zeros(1,length(evidence)) ;
min_states(1,d1) = min1(1,d1) ;

consistency = 0 ;

for i=2:nc
    c2 = clpot{i} ;
    d2 = c2.domain ;
    js2 = full_combination_new(c2.sizes) ;
    ind = find(c2.T==1) ;
    
%     for k=1:length(ind)
%         min2(k,d2) = js2(ind(k),:); 
%     end
    min2(1,d2) = js2(ind(1),:) ;
    
    pv = intersect(d1,d2) ;
    
    if isempty(pv)
       min_states(1,d1) = min1(1,d1) ;
       min_states(1,d2) = min2(1,d2) ;
       consistency = 1 ;
    else if min1(1,pv) == min2(1,pv)
            consistency = 1 ;
            min_states(1,d1) = min1(1,d1) ; 
            min_states(1,d2) = min2(1,d2) ;            
        end
    end    
    
    if (consistency == 0)
        fprintf('**************************************************************** \n'); 
        fprintf('*** Need to investigate: states consistency problem! -wsun *** \n'); 
        fprintf('*** Need to investigate: states consistency problem! -wsun *** \n'); 
        fprintf('*** These inconsistent states usually have same min-q. -wsun *** \n\n');         
        %pause
        min1(pv)
        min2(pv)
        %error('Need to investigate: states consistency problem! -wsun ***'); 
        min_states1 = min_states ;
        min_states2 = min_states ;
        min_states1(1,d1) = min1(1,d1) ; 
        min_states1(1,d2) = min2(1,d2) ;
        min_states1(1,d1) = min1(1,d1) ; 
        min_states2(1,d2) = min2(1,d2) ; 
        
        min_states = min_states2 ;
        %return ;
    end
    d1 = union(d1,d2); 
    min1 = min_states ;
    consistency = 0 ; 
end

hidden = find(isemptycell(evidence)) ;
lpe.domain = hidden ;
lpe.states = min1(:,hidden) ;


                
   