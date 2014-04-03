function [lpe, ll] = calc_lpe(engine, evidence, break_ties)
% CALC_LPE Computes the least probable explanation of the evidence
% [lpe, ll] = calc_mpe_given_inf_engine(engine, evidence, break_ties)
%
% - I wrote this code to calculate LPE based on modifying BNT function
% 'calc_mpe(engine,evidence,break_ties)
% -wsun, 10/28/11
%
% INPUT
% engine must support max-propagation
% evidence{i} is the observed value of node i, or [] if hidden
% break_ties is optional. If 1, we will force ties to be broken consistently
%  by calling enter_evidence N times.
%
% OUTPUT
% mpe{i} is the most likely value of node i (cell array!)
% ll is the log-likelihood of the globally best assignment
%
% This currently only works when all hidden nodes are discrete

if nargin < 3, break_ties = 0; end


[engine, ll] = enter_evidence(engine, evidence, 'minimize', 1);

observed = find(~isemptycell(evidence)) ;

if 0 % fgraphs don't support bnet_from_engine
onodes = find(observed);
bnet = bnet_from_engine(engine);
pot_type = determine_pot_type(bnet, onodes);
assert(pot_type == 'd');
end

% if 0 %old BNT code to calculate MPE/LPE
% scalar = 1;
% evidence = evidence(:); % hack to handle unrolled DBNs
% N = length(evidence);
% lpe = cell(1,N);
% for i=1:N
%   m = marginal_nodes(engine, i);
%   % observed nodes are all set to 1 inside the inference engine, so we must undo this
%   if observed(i)
%     lpe{i} = evidence{i};
%   else
%     lpe{i} = argmin(m.T);
%     % Bug fix by Ron Zohar, 8/15/01
%     % If there are ties, we must break them as follows (see Jensen96, p106)
%     if break_ties
%       evidence{i} = lpe{i};                             
%       [engine, ll] = enter_evidence(engine, evidence, 'minimize', 1);  
%     end
%   end
%   if length(lpe{i}) > 1, scalar = 0; end
% end
% end

clpot = clpot_from_engine(engine) ;
lpe = find_lpe_sun(clpot, evidence) ;



if nargout >= 2
  bnet = bnet_from_engine(engine);
  ll = log_lik_complete(bnet, lpe(:));
end
if 0 % scalar
  lpe = cell2num(lpe);
end
