function [clpot, seppot] = distribute_evidence(engine, clpot, seppot)
% DISTRIBUTE_EVIDENCE Do message passing from root to leaves (parents then children)
% [clpot, seppot] = distribute_evidence(engine, clpot, seppot)

% modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
% 'moption' means marginization option. 
% -wsun
if engine.maximize == 1
    moption = 'max'; 
else if engine.minimize == 1
        moption = 'min'; 
    else
        moption = 'sum';
    end
end

for n=engine.preorder
  for c=engine.preorder_children{n}
    clpot{c} = divide_by_pot(clpot{c}, seppot{n,c}); 
    %seppot{n,c} = marginalize_pot(clpot{n}, engine.separator{n,c}, engine.maximize);
    %modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
    %-wsun
    seppot{n,c} = marginalize_pot(clpot{n}, engine.separator{n,c}, moption);
    clpot{c} = multiply_by_pot(clpot{c}, seppot{n,c});
  end
end
