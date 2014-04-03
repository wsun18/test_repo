function [engine, loglik] = enter_evidence(engine, evidence, varargin)
% ENTER_EVIDENCE Add the specified evidence to the network (jtree)
% [engine, loglik] = enter_evidence(engine, evidence, ...)
%
% evidence{i} = [] if X(i) is hidden, and otherwise contains its observed value (scalar or column vector).
%
% The following optional arguments can be specified in the form of name/value pairs:
% [default value in brackets]
%
% soft    - a cell array of soft/virtual evidence;
%           soft{i} is a prob. distrib. over i's values, or [] [ cell(1,N) ]
%
% e.g., engine = enter_evidence(engine, ev, 'soft', soft_ev)

bnet = bnet_from_engine(engine);
ns = bnet.node_sizes(:);
N = length(bnet.dag);

engine.evidence = evidence; % store this for marginal_nodes with add_ev option
engine.maximize = 0;

% set default params
exclude = [];
soft_evidence = cell(1,N);

% parse optional params
args = varargin;
nargs = length(args);
for i=1:2:nargs
  switch args{i},
   case 'soft',    soft_evidence = args{i+1}; 
   case 'maximize', engine.maximize = args{i+1};
   case 'minimize', engine.minimize = args{i+1}; % added on 10/28/11, for min-calibration, -wsun
   otherwise,  
    error(['invalid argument name ' args{i}]);       
  end
end

onodes = find(~isemptycell(evidence));
hnodes = find(isemptycell(evidence));
pot_type = determine_pot_type(bnet, onodes);
if strcmp(pot_type, 'cg')
  check_for_cd_arcs(onodes, bnet.cnodes, bnet.dag);
end

if is_mnet(bnet)
  pot = engine.user_pot;
  clqs = engine.nums_ass_to_user_clqs;
else
  % Evaluate CPDs with evidence, and convert to potentials  
  pot = cell(1, N);
  for n=1:N
    fam = family(bnet.dag, n);
    %nm = bnet.node_names{n} ;
    e = bnet.equiv_class(n);
    if isempty(bnet.CPD{e})
      error(['must define CPD ' num2str(e)])
    else
      pot{n} = convert_to_pot(bnet.CPD{e}, pot_type, fam(:), evidence);
      if length(pot{n}.T(:)) ~= prod(pot{n}.sizes)
          fprintf('ATTention!!! ********\n') ;
          n
          pot{n} 
          pause          
      end      
    end
  end
  clqs = engine.clq_ass_to_node(1:N);
end

% soft evidence
soft_nodes = find(~isemptycell(soft_evidence));
S = length(soft_nodes);
if S > 0
  assert(pot_type == 'd');
  assert(mysubset(soft_nodes, bnet.dnodes));
end
for i=1:S
  n = soft_nodes(i);
  pot{end+1} = dpot(n, ns(n), soft_evidence{n});
end
clqs = [clqs engine.clq_ass_to_node(soft_nodes)]; 


[clpot, seppot] = init_pot(engine, clqs, pot, pot_type, onodes);
[clpot, seppot] = collect_evidence(engine, clpot, seppot);
[clpot, seppot] = distribute_evidence(engine, clpot, seppot);

C = length(clpot);
if 1 % normalization 
if engine.maximize == 1 % max-normalization
    for i=1:C
        clpot{i}.T = clpot{i}.T / max(clpot{i}.T(:)) ;
    end    
else 
    if engine.minimize==1 % min-normalization
        for i=1:C
            if find(clpot{i}.T==0)
                clpot{i}.T(find(clpot{i}.T==0)) = 1.1 ;
                clpot{i}.T = clpot{i}.T / min(clpot{i}.T(:)) ;
            else
                clpot{i}.T = clpot{i}.T / min(clpot{i}.T(:)) ;
            end
        end    
    else % normalization after regular sum-propagation of clique tree algorithm.
        for i=1:C
            [clpot{i}, ll(i)] = normalize_pot(clpot{i});
        end
        loglik = ll(1); % we can extract the likelihood from any clique
    
% Normalizing separator potentials, added on 11/7/2011, -wsun. 
% After adding this part of code, calculating the joint by (product of
% cliques potentials) / (product of separators potentials) returned correct
% results. :)
        for n=engine.postorder  
            for p=engine.postorder_parents{n}
                seppot{p,n} = normalize_pot(seppot{p,n});
            end
        end   
    end
end
end
   
loglik = .333; % since I do not need this loglik value so far, I return this temporary value. -wsun, 11/13/11. 
engine.clpot = clpot;
engine.seppot = seppot; % added on 11/3/2011, -wsun.
