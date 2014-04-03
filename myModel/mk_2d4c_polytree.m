function bnet = mk_2d4c_polytree(CPD_type, arity)

  
%            T      K
%             \    / 
%              o  o   
%              (W)o---(Y)
%               |      |
%               o      o
%              (Z)    (L)
% 

%disp('Creating a CLG network ...');

if nargin == 0, CPD_type = 'orig'; end
if nargin < 2, arity = 1; end

if ~ismember(CPD_type, {'orig', 'rnd', 'nonlinear'})
    error('Error, wrong CPD type. Line 28') ;
    return ;
end    

K = 1 ;
T = 2 ;
KT_comb = 3 ;
Y = 4 ;
W = 5 ;
Z = 6 ;
L = 7 ;

node_names = {'K', 'T', 'KT_comb', 'Y', 'W', 'Z', 'L'} ;

n = 7;
dag = zeros(n);
dag([K T], KT_comb) = 1;
dag([KT_comb Y],W) = 1;
dag(W,Z) = 1;
dag(Y,L) = 1;

dnodes = [K T KT_comb] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n); 
ns(dnodes) = 2 ;
ns(KT_comb) = 4 ;

bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', node_names);

switch CPD_type
    case 'orig',         
        bnet.CPD{K} = tabular_CPD(bnet, K, [0.8 0.2]);
        bnet.CPD{T} = tabular_CPD(bnet, T, [0.3 0.7]);
        bnet.CPD{KT_comb} = tabular_CPD(bnet, KT_comb, [1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1]);
            
        bnet.CPD{Y} = gaussian_CPD(bnet, Y, 'mean', 3, 'cov', 1) ;    

        bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [2 1 -2 0], ...
            'cov', [1 1 1 1], 'weights', [1.0 1.0 1.0 1.0 ]);
        
%         bnet.CPD{W} = gaussian_CPD(bnet, W, 'mean', [2 1 -2 0], ...
%             'cov', [1 1 1 1], 'weights', [1.0 1.0 1.0 1.0 ], ...
%             'function', {sym('Y'),sym('Y'),sym('Y'),sym('Y')}) ; 
                
        bnet.CPD{Z} = gaussian_CPD(bnet, Z, 'mean', 5, ...
            'cov', 1, 'weights', 0.5) ;
        
        bnet.CPD{L} = gaussian_CPD(bnet, L, 'mean', 0, ...
            'cov', 1, 'weights', 0.5) ;
    case 'rnd',
        for i=dnodes
            bnet.CPD{i} = tabular_CPD(bnet, i);
        end
            
        for j=cnodes
            bnet.CPD{j} = gaussian_CPD(bnet, j, 'cov', 1*eye(ns(j)));
        end
    otherwise,
        error('Error, wrong CPD type. Line 28') ;
        return ;
end
