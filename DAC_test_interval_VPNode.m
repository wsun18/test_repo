% test how dynamic asset model works on VP-node (value partitioning node),
% using interval representation in general.
% -wsun, Jan. 29, 2014

clear
clear all
clear classes %whenever you change a class definition, you need to call this.
close all
home
fprintf('\n')
disp('====================================')
disp('Prob. and Asset Updating using BN for Prediction Market')

myHome = '/Users/wsun/wsunCloud/Dropbox/myResearch/matlab/DAC_';
addpath(fullfile(myHome, 'myModel')) ;
addpath(fullfile(myHome, 'wsun_lib')) ;
addpath(fullfile(myHome, 'Lib_')) ;
addpath(fullfile(myHome, 'BruteForceFunc_')) ;

global S b log_base vList vSizes;
S=1000; b=100; log_base=2; 
vList = {} ;
vSizes = [] ;

%%%%% ============ prob. and asset initialization
thh1 = .001 ; % threshold for probability
thh2 = .1 ; % threshold for asset
ResQ = {} ; % initialize resolved question list
resQ = [] ; % initialize resolved states vector
% AddQ = {} ; % initialize added question list

%%%%% ============ user initialization
nofu = 1 ;
user = cell(1,nofu) ;

% A use case takes a VP-node having Jan 2014 to July 2015 as the overall
% period to trade on, correspondingly, I use numbers 1 to 19 to represent
% those individual months.
% (1) Initially, assume uniform probabilities over all months.
% (2) Probability update goes to unit level after any trade for VP node.
%    (a) each unit in target range changes at the same ratio as the whole
%        range
%    (b) same ratio change for the atom units in the other part of the 
%        reference range than target range.  

nos = 19 ; % number of states for the VP-node
p0 = 1/nos * ones(nos,1) ; % assume initial uniform prob.
% bar(p,.3)

a = zeros(nos,1) ;

cu = 1 ;
addCash = 0 ;

% initializing user
user{cu}.manna = addCash ;
user{cu}.base = S + addCash ;

dac.base = S + addCash; 
dac.Obj_list={}; %%%% for saving VP nodes?? 
dac.Q_list = {}; 
dac.ns = []; dac.abc={}; 
user{cu}.dac = dac ;

rain_VP.strname = 'Rain' ; % a sample VP question
rain_VP.min = 1 ;
rain_VP.max = 19 ;
rain_VP.cutpoints = [] ;

%% First case: p(tr)
target_range = [3, 10] ;

% current probability over the range of [3,10] is ~0.42105, let us decrease
% it by 15%, then the new probability distribution is p1.
c_per1 = -.15 ;
p1 = DAC_VP_calc_new_prob(p0, target_range, [1,19], c_per1) ;

p1./p0  % to check the changing ratio.
b*log2(p1./p0)  % to find the asset change

delta1 = [-23.4465254, 14.9377624] ;  % 
[user{cu}.dac, rain_VP]  = DAC_VP_updateUserAssetBlocks(user{cu}.dac, rain_VP, delta1, ...
    target_range) ;


%% Second case p(tr|rr) still on rain_VP
target_range = [8,9] ;
reference_range = [5, 13] ;

c_per2 = .25 ;
p2 = DAC_VP_calc_new_prob(p1, target_range, reference_range, c_per2) ;

p2./p1  % to check the changing ratio.
b*log2(p2 ./ p1)  % to check the asset change.

delta2 = [32.1928095, -9.41495595] ;
[user{cu}.dac, rain_VP] = DAC_VP_updateUserAssetBlocks(user{cu}.dac, rain_VP, delta2, ...
    target_range, reference_range) ;


%% Third case: p(tr|rr, A), 'sand_VP' given 'A'
%  Add a regular question as parent of the VP, and then use it as one
%  assumption question.


% bnet1 = mk_bnet_VP_A() ;

sand_VP.strname = 'sand' ; % a sample VP question
sand_VP.min = 1 ;
sand_VP.max = 10 ;
sand_VP.cutpoints = [] ;

prob_A = [.3, .7] ;
p1 = ones(1,10)/10 ;  % prob_sandVP_given_A1
p2 = ones(1,10)/10 ;  % prob_sandVP_given_A2

tr3 = [7,9] ;
rr3 = [4,10] ;

Assm = {'A'} ;
assm = 2 ;
A_sz = 2 ;

c_per3 = -0.2333 ;  % % probability change percent, reduce 20% of the corresponding probability.

p3 = DAC_VP_calc_new_prob(p2, tr3, rr3, c_per3) ;

b*log2(p3 ./ p2) 

delta3 = [-38.3266, 23.263] ; % can be verifed by 'b*log2(new_p2 ./ p2)'.
 
[user{cu}.dac, sand_VP] = DAC_VP_updateUserAssetBlocks(user{cu}.dac, sand_VP, delta3, ...
    tr3, rr3, Assm, assm, A_sz) ;

dac_cash = DAC_find_cash(user{cu}.dac) 
% 
% true_cash = ?
% assert(abs(dac_cash - true_cash) <= thh2) ;



%% fourth case: p(tr|rr, VP_Assm)  'ground_VP' given 'sky_VP'
sky_VP.strname = 'Sky' ; % a VP question as the only assumption question.
sky_VP.min = 1 ;
sky_VP.max = 4 ;
sky_VP.cutpoints = [] ;

% assuming initially the prior distribution of VP_A is uniform
prob_VP_A = .25*ones(1,4) ;
    
% the given range of the VP assumption question to be conditioned on. 
tr_assm = [2,4] ; 

% regular assumption question set is empty.
Assm = {} ; 
assm = [] ;
A_sz = [] ;

% use a new VP-node called 'Ground' as the target VP-node for the test trade
ground_VP.strname = 'Ground' ;
ground_VP.min = 1 ;
ground_VP.max = 10 ;
ground_VP.cutpoints = [] ;
tr4 = [3,5] ;  % target range of the target VP-node
rr4 = [1,9] ;  % reference range of the target VP-node

% the atomic units of VP_Assm are: {1, 2, 3, 4}.
% Given the target range of the VP assumption question, the current
% conditional probability of sand_VP is the weighted sum of the individual
% conditional probability distributions:  

pp1 = .1*ones(1,10) ; 

tp2 = [.1, .15, .08, .05, .2, .11, .3, .22, .05, .15] ;  
pp2 = tp2/sum(tp2) ;  % prob. distr. given VP_Assm = 2 

tp3 = [.03, .1, .1, .25, .15, .6, .20, .05, .13, .2] ;
pp3 = tp3/sum(tp3) ;  % prob. distr. given VP_Assm = 3

tp4 = [.2, .5, .1, .15, .05, .18, .08, .19, .20, .25] ;
pp4 = tp4/sum(tp4) ;  % prob. distr. given VP_Assm = 4


% given VP_A = [2 4], we then know the conditional probility distribution 
% of VP_trade is the weighted sum of pp2, pp3, pp4:
pps = (1/3)*pp2 + (1/3)*pp3 + (1/3)*pp4 ;

pc_percent = .30 ; % probability change percent, increase by 30%

new_pps = DAC_VP_calc_new_prob(pps, tr4, rr4, pc_percent) ;

% figure(1)
% subplot(1,2,1)
% bar(pps,.3)
% subplot(1,2,2)
% bar(new_pps,.3)

b*log2(new_pps./pps)

delta4 = [37.85116, -15.37159] ; % can be verifed by 'b*log2(new_pps ./ pps)'.

[user{cu}.dac, ground_VP, VP_Assm] = DAC_VP_updateUserAssetBlocks(user{cu}.dac, ground_VP, delta4, ...
    tr4, rr4, Assm, assm, A_sz, {sky_VP}, tr_assm) ; % using {VP_Assm} as the general form due to possible multiple VP assumption nodes.

sky_VP = VP_Assm{1} ; % update sky_VP, mainly for its new cutpoints.



%% fifth case: p(tr|rr, A, VP_Assm)  'sand_VP' given 'A', and 'sea_VP'.
%  In the third case, we have a trade p(tr|rr,A) on the VP-node 'sand_VP',
%  which resulted in a asset block with two variables 'sand_VP' and 'A',
%  and corresponding 4x2 asset table. We now add another VP-node called
%  'sea_VP' to be a VP-parent for 'sand_VP', then make a trade
%  p(tr|rr,A,VP_Assm).

sea_VP.strname = 'sea' ; % a VP question as the only assumption question.
sea_VP.min = 1 ;
sea_VP.max = 5 ;
sea_VP.cutpoints = [] ;

% assuming initially the prior distribution of VP_A is uniform
prob_VP_sea = .2*ones(1,5) ;
    
% the given range of the VP assumption question to be conditioned on. 
tr_assm = [2,4] ; 

% regular assumption question set is empty.
Assm = user{cu}.dac.Q_list(3) ; % the regular question 'A' used as the assumption in third trade above.
assm = 1 ;
A_sz = 2 ;

% targ_range and ref_range for VP_trade, which is 'sand_VP' in this case
tr5 = [3,5] ;
rr5 = [2,8] ;

% the atomic units of VP_Assm are: {1, 2, 3, 4}.
% Given Assm=assm, and also the target range of the VP assumption question, 
% assuming the current conditional probability of sand_VP are the
% following:

% pp1 = .1*ones(1,10) ; 

tp2 = [.1, .15, .08, .05, .2, .11, .3, .22, .05, .15] ;  
pp2 = tp2/sum(tp2) ;  % prob. distr. given VP_Assm = 2 

tp3 = [.03, .1, .1, .25, .15, .6, .20, .05, .13, .2] ;
pp3 = tp3/sum(tp3) ;  % prob. distr. given VP_Assm = 3

tp4 = [.2, .5, .1, .15, .05, .18, .08, .19, .20, .25] ;
pp4 = tp4/sum(tp4) ;  % prob. distr. given VP_Assm = 4


% given VP_Assm = [2 4] and Assm=assm, we then know the conditional probility distribution 
% of VP_trade is the weighted sum of pp2, pp3, pp4:
pps = (1/3)*pp2 + (1/3)*pp3 + (1/3)*pp4 ;

pc_percent = -.20 ; % probability change percent, decrease by 20%

new_pps = DAC_VP_calc_new_prob(pps, tr5, rr5, pc_percent) ;

b*log2(new_pps./pps)

delta5 = [-32.1928, 11.7275] ; % can be verifed by 'b*log2(new_pps ./ pps)'.

[user{cu}.dac, sand_VP, VP_Assm] = DAC_VP_updateUserAssetBlocks(user{cu}.dac, sand_VP, delta5, ...
    tr5, rr5, Assm, assm, A_sz, {sea_VP}, tr_assm) ; % using {VP_Assm} as the general form due to possible multiple VP assumption nodes.

sea_VP = VP_Assm{1} ;


%% Case 6: resolving a VP node
%  When we resolve a VP-node, we always go to its atomic unit, then we need to
%  map the resolved atomic state to the corresponding user's interval
%  state, because VP-node's interval state may be different in user's asset 
%  blocks
RVar = {sky_VP, 'A'} ;
rState = [3, 1] ;  % This is an atomic unit, we need to map it into interval state in user's asset blocks.

user{cu}.dac = DAC_VP_updateUserAssetBlocks_Resolving(user{cu}.dac, RVar, rState) ;




%% case 7: determine the trade limit of a trade on VP-node assuming new 
%          target range and reference ranage in general. 
%
%%%%% ********* working on it ************** %%%%%%%%%%
%
% The key is to find conditional cash given a set of questions being
% instantialized, including VP questions to be set to some interval (NOTE
% not to be set into atomic unit).
% dac_cash = DAC_VP_find_cash(user{cu}.dac, RVar, rState) ;





