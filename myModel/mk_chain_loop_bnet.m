function bnet = mk_chain_loop_bnet(CPD_type, p, arity)
% This is to create a very simple pure discrete network 


if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

% if ~ismember(CPD_type, {'orig', 'gauss', 'rndgauss', ...
%         'bool', 'clg', 'nonlinear', 'uniform'})
%     error('Error, wrong CPD type. Line 37') ;
%     return ;
% end    

A = 1;
B = 2;
C = 3;
D = 4; 
E = 5;

n = 5;
dag = zeros(n);
dag(A, B) = 1;
dag(B, C) = 1;
dag(C, D) = 1;
dag(D, E) = 1;
dag(A, E) = 1;

% if strcmp(CPD_type, 'gauss') || strcmp(CPD_type, 'rndgauss') || strcmp(CPD_type, 'nonlinear')
%     dnodes = [];
%     else if strcmp(CPD_type, 'clg')
%             dnodes = [1 2];
%         else if strcmp(CPD_type, 'orig') || strcmp(CPD_type,'uniform')
%                 dnodes = 1:n;
%             end
%         end
% end

dnodes = 1:n ;

ns = arity*ones(1,n);
ns(dnodes) = 2 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'A','B','C','D','E'});

% specify uniform  CPDs for all nodes
for k=1:n
    bnet.CPD{k} = tabular_CPD(bnet, k,'CPT','unif') ;
end


% switch CPD_type
%   case 'orig',     
%     % present is 1, absent is 2
%     bnet.CPD{D} = tabular_CPD(bnet, D, [0.5 0.5]);
%     % increased is 1, not increased is 2
%     bnet.CPD{E} = tabular_CPD(bnet, E, [0.9 0.4 0.1 0.6]);
%     % present is 1, absent is 2
%     bnet.CPD{F} = tabular_CPD(bnet, F, [0.30 0.10 0.70 0.90]);
%   case 'uniform'
%     bnet.CPD{D} = tabular_CPD(bnet, D, [0.5 0.5]);    
%     bnet.CPD{E} = tabular_CPD(bnet, E, [0.5 0.5 0.5 0.5]);    
%     bnet.CPD{F} = tabular_CPD(bnet, F, [0.5 0.5 0.5 0.5]);        
% end
% 
  
  
