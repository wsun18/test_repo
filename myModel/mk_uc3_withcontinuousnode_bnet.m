function bnet = mk_uc3_withcontinuousnode_bnet(CPD_type, p, arity)

%
%               hasAgressiveBehavior
%                /     /   \      \
%               *     /     \      * 
%  hasWeaponVisible  *       *   isJettisoningCargo
%          (SpeedChange)*---(TurnRate)
%                 / \          /  \
%                /   \        /    \
%               /     \      /      \
%              *       *    *        *
% (propellerTurnCount)(cavitation)  (shipRCSchange)
% 
% 

if nargin == 0, CPD_type = 'orig'; end
if nargin < 3, arity = 1; end

if ~ismember(CPD_type, {'orig', 'gauss', 'rndgauss', 
        'bool', 'cpt', 'nonlinear'})
    error('Error, wrong CPD type. Line 37') ;
    return ;
end    

hasAgressiveBehavior = 1;
hasWeaponVisible = 2;
isJettisoningCargo = 3;
TurnRate = 4;
SpeedChange = 5;
propellerTurnCount = 6;
cavitation = 7;
shipRCSchange = 8;

n = 8;
dag = zeros(n);

dag(hasAgressiveBehavior, [SpeedChange TurnRate hasWeaponVisible isJettisoningCargo]) = 1;
dag(TurnRate, SpeedChange) = 1;
dag([SpeedChange TurnRate], cavitation) = 1;
dag(SpeedChange, propellerTurnCount) = 1;
dag(TurnRate, shipRCSchange) = 1;
 

dnodes = [hasAgressiveBehavior hasWeaponVisible isJettisoningCargo] ;
cnodes = mysetdiff(1:n, dnodes);
ns = arity*ones(1,n);  
ns(dnodes) = 2 ;
  
bnet = mk_bnet(dag, ns, 'discrete', dnodes, 'names', {'hasAgressiveBehavior', 'hasWeaponVisible',...
    'isJettisoningCargo', 'TurnRate','SpeedChange','propellerTurnCount', 'cavitation', 'shipRCSchange'});

switch CPD_type
 case 'gauss',
     
        bnet.CPD{hasAgressiveBehavior} = tabular_CPD(bnet, hasAgressiveBehavior, [0.4 0.6]);
        
        bnet.CPD{hasWeaponVisible} = tabular_CPD(bnet, hasWeaponVisible, [0.5 0.3 0.5 0.7]);
        bnet.CPD{isJettisoningCargo} = tabular_CPD(bnet, isJettisoningCargo, [0.5 0.3 0.5 0.7]);
        
        bnet.CPD{TurnRate} = gaussian_CPD(bnet, TurnRate, 'mean', [30 15], 'cov', [1 3]) ;
        
        bnet.CPD{SpeedChange} = gaussian_CPD(bnet, SpeedChange, 'mean', [5 20 ], ...
            'cov', [1 2], 'weights', [0.5 1.0], ...
            'function', {sym('0.5*TurnRate'),sym('TurnRate')}) ;  
        
        bnet.CPD{propellerTurnCount} = gaussian_CPD(bnet, propellerTurnCount, 'mean', 0, 'cov', 1, 'weights',0.5, ...
            'function', {sym('0.5*SpeedChange')} ) ;
        
        bnet.CPD{shipRCSchange} = gaussian_CPD(bnet, shipRCSchange, 'mean', 0, 'cov', 1, 'weights',0.5, ...
            'function', {sym('0.5*TurnRate')} ) ;
        
        bnet.CPD{cavitation} = gaussian_CPD(bnet, cavitation, 'mean', [5], ...
            'cov', [1], 'weights', [1.0 -0.5], ...
            'function', {sym('SpeedChange - 0.5*TurnRate')}) ;    
      
      %  bnet.CPD{cavitation} = gaussian_CPD(bnet, cavitation, 'mean', [5 20 10 -5], ...
      %      'cov', [1 2 1 0.5], 'weights', [1.0 -0.5 1.0 1.0 -1.0 1.0 0.5 1.0], ...
      %      'function', {sym('SpeedChange - 0.5*TurnRate'),sym('SpeedChange + TurnRate'),sym('-SpeedChange + TurnRate'),sym('0.5*SpeedChange + TurnRate')}) ;    
         
 case 'nonlinear', 
     bnet.CPD{MetaCancer} = gaussian_CPD(bnet, MetaCancer, ...
         'mean', 10, 'cov', 1) ;
     bnet.CPD{SerumCalcium} = gaussian_CPD(bnet, SerumCalcium, ...
         'mean', 5, 'cov', 1, ...
         'function', {sym('log(MetaCancer)')} ) ;
     bnet.CPD{BrainTumor} = gaussian_CPD(bnet, BrainTumor, ...
         'mean', 0, 'cov', 1, ...
         'function', {sym('exp(sqrt(MetaCancer))')} ) ;
     bnet.CPD{Coma} = gaussian_CPD(bnet, Coma, ...                  
         'mean', 0, 'cov', 1, ...
         'function', {sym('SerumCalcium + sqrt(BrainTumor)')} ) ;
     bnet.CPD{SHeadaches} = gaussian_CPD(bnet, SHeadaches, ...
         'mean', 0, 'cov', 0.5, ...
         'function', {sym('0.5*BrainTumor')} ) ;            
 case 'cpt',
  for i=1:n
    bnet.CPD{i} = tabular_CPD(bnet, i, p);
  end
end

  
  
