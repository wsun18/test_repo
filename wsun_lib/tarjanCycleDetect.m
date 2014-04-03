function SCC = tarjanCycleDetect(dag)
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
        S = [] ;
    end
    if ~isempty(SCC)
        return ;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strongConnComponent(dag,k)

global index V S SCC ;

V{k}.index = index ;
V{k}.lowlink = index ;
index = index + 1 ;

S(end+1) = k 

childset = find(dag(k,:)>0) 

for i=childset
    i
    if isempty(V{i})
        strongConnComponent(dag,i) ;
        V{k}.lowlink = min(V{k}.lowlink, V{i}.lowlink) ;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% in between modified by wsun 
        if ~isempty(SCC)
            return ;
        end
        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif myintersect(S,i)
        V{k}.lowlink = min(V{k}.lowlink, V{i}.lowlink) ;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% in between modified by wsun 
        movInd = find(S==i) ;
        while S(movInd) ~= k
            SCC(end+1) = S(movInd) ;
            movInd = movInd + 1 ;
        end
        SCC(end+1) = k ;
        SCC(end+1) = i ;
        return ;
        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

% if (V{k}.lowlink == V{k}.index)   
%     k 
%     S
%     while (k ~= S(end))
%         SCC(end+1) = S(end) ;
%         S = mysetdiff(S,S(end)) ;
%     end
%     SCC(end+1) = k ;
%     L = length(SCC) ;
%     movInd = L ;
%     for j=1:L
%         tp(j) = SCC(movInd) ;
%         movInd = movInd - 1 ;
%     end
%     SCC = tp ;
% end





