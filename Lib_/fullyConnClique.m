function bnet = fullyConnClique(bnet)
% This is to make variables in the same cliques fully connected with each other
% if they have not been so.
% -wsun, 12/19/2012

dag = bnet.dag ;
engine = jtree_inf_engine(bnet);
clqs = cliques_from_engine(engine) ;

for k=1:length(clqs)
    vset = clqs{k} ;
    if length(vset) > 2
        sub_dag = dag(vset,vset) ;
        A1 = tril(sub_dag) ; A2 = triu(sub_dag) ;
        tdag = A1' + A2 ;
        for i=1:length(tdag)
            instance = tdag(i,:) ;
            candset = find(instance==0) ;
            candset = mysetdiff(candset,i) ;
            for j=candset
                sub_dag(i,j) = 1 ;
                dag(vset,vset) = sub_dag ;
                SSC = tarjanCycleDetect(dag) ;
                if 
            end
            
        end
        yy = 3 ;
    end
end

