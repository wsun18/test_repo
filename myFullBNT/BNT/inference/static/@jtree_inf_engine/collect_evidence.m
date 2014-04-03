function [clpot, seppot] = collect_evidence(engine, clpot, seppot)
% COLLECT_EVIDENCE Do message passing from leaves to root (children then parents)
% [clpot, seppot] = collect_evidence(engine, clpot, seppot)

%engine.postorder = [6 1 2 4 3 5] ; % for helping to debug UnBBayes with Aditya, 4/29/10.
%engine.postorder = [2 4 6 1 3 5] ; % for helping to debug Aditya's code, 1/15/11.

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

for n=engine.postorder %postorder(1:end-1)
  for p=engine.postorder_parents{n}
    clpot{p} = divide_by_pot(clpot{p}, seppot{p,n}); % dividing by 1 is redundant
    %seppot{p,n} = marginalize_pot(clpot{n}, engine.separator{p,n}, engine.maximize);
    %modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
    %-wsun
    seppot{p,n} = marginalize_pot(clpot{n}, engine.separator{p,n}, moption);    
    clpot{p} = multiply_by_pot(clpot{p}, seppot{p,n});
  end
end

