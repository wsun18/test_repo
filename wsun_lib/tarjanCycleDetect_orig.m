function SCC = tarjanCycleDetect_orig(dag)
% This is to implement the Tarjan cycle detection algorithm. Wiki link for
% its details:
% http://en.wikipedia.org/wiki/Tarjan's_strongly_connected_components_algorithm
% SCC stands for strong connected component, which means a set of nodes
% forming a cycle.
% -wsun, 12/19/2012

global index V S SCC ;
index = 1 ;
S = [] ;
SCC = [] ;

N = length(dag) ;
V = cell(1,N) ;

for k=1:N
    if isempty(V{k})
        strongConnComponent(dag,k) ;        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strongConnComponent(dag,k)

global index V S SCC ;

V{k}.index = index ;
V{k}.lowlink = 10000 ;  % initializing lowlink to be a big number.
index = index + 1 ;

S(end+1) = k ;

childset = find(dag(k,:)>0) ;

for i=childset    
    if isempty(V{i})
        strongConnComponent(dag,i) ;
        V{k}.lowlink = min(V{k}.lowlink, V{i}.lowlink) ;
    elseif myintersect(S,i)
        V{k}.lowlink = min(V{k}.lowlink, V{i}.index) ;        
    end
    if (V{k}.lowlink == V{k}.index)   
        tp_S = S ;
        while (k ~= tp_S(end))
            SCC(end+1) = tp_S(end) ;
            tp_S = mysetdiff(tp_S,tp_S(end)) ;
        end
        SCC(end+1) = k ;
        tp_S = [] ;
        return ;
    end
end

% 
% if (V{k}.lowlink == V{k}.index)   
%     tp_S = S ;
%     while (k ~= tp_S(end))
%         SCC(end+1) = tp_S(end) ;
%         tp_S = mysetdiff(tp_S,tp_S(end)) ;
%     end
%     SCC(end+1) = k ;
%     tp_S = [] ;
% %     if length(SCC)==1
% %         SCC = [];
% %     end
% end





