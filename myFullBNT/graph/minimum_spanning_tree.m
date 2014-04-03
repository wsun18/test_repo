function A = minimum_spanning_tree(C1, C2)
%
% Find the minimum spanning tree using Prim's algorithm.
% C1(i,j) is the primary cost of connecting i to j.
% C2(i,j) is the (optional) secondary cost of connecting i to j, used to break ties.
% We assume that absent edges have 0 cost.
% To find the maximum spanning tree, used -1*C.
% See Aho, Hopcroft & Ullman 1983, "Data structures and algorithms", p 237.

% Prim's is O(V^2). Kruskal's algorithm is O(E log E) and hence is more efficient
% for sparse graphs, but is implemented in terms of a priority queue.

% We partition the nodes into those in U (cliques in JT already) and those
% not in U, denoted as NU (for cliques not in JT yet).
% closest(i) is the vertex in NU that is closest to i_th cliques in U.
% lowcost(i) is the cost of the edge (i, closest(i)), or infinity is i has been used.
% In Aho, they say C(i,j) should be "some appropriate large value" if the edge is missing.
% We set it to infinity.
% However, since lowcost is initialized from C, we must distinguish absent edges from used nodes.

n = length(C1);
if nargin==1, C2 = zeros(n); end
A = zeros(n);

closest = ones(1,n);
used = zeros(1,n); % contains the members of U
used(1) = 1; % start from the first clique in the list
C1(find(C1==0))=inf;
C2(find(C2==0))=inf;
lowcost1 = C1(1,:);
lowcost2 = C2(1,:);

if 0
%%%%%%%%% original in BNT %%%%%%%%%%
for i=2:n
  ks = find(lowcost1==min(lowcost1));
  k = ks(argmin(lowcost2(ks)));
  A(k, closest(k)) = 1;
  A(closest(k), k) = 1;
  lowcost1(k) = inf;
  lowcost2(k) = inf;
  used(k) = 1;
  NU = find(used==0);
  for ji=1:length(NU)
    for j=NU(ji) %% no need to use 'for'
      if C1(k,j) < lowcost1(j)
	lowcost1(j) = C1(k,j);
	lowcost2(j) = C2(k,j);
	closest(j) = k;
      end
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%% modified on 11/2/09, by wsun, reason: no need to use 'for' loop as
%%% shown in the original code above.
for i=2:n
  ks = find(lowcost1==min(lowcost1));
  k = ks(argmin(lowcost2(ks)));
  A(k, closest(k)) = 1;
  A(closest(k), k) = 1;
  lowcost1(k) = inf;
  lowcost2(k) = inf;
  used(k) = 1;
  NU = find(used==0);
  % lowcost2 and lowcost2 are calculated from the prespective of 
  % considering partial tree. -wsun, 4/19/10.
  for j=NU
    if C1(k,j) < lowcost1(j)
        lowcost1(j) = C1(k,j);
        lowcost2(j) = C2(k,j);
        closest(j) = k;
    end
    % added on 4/19/10, should consider the case of having smaller size.
    if C1(k,j) == lowcost1(j) & C2(k,j) < lowcost2(j)        
        lowcost2(j) = C2(k,j);
        closest(j) = k;
    end
  end
end



