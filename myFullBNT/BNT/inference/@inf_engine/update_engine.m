%function engine = update_engine(engine, newCPDs)
function engine = update_engine(engine, varargin)
% UPDATE_ENGINE Update the engine to take into account the new parameters (inf_engine).
% engine = update_engine(engine, newCPDs)
%
% This generic method is suitable for engines that do not process the parameters until 'enter_evidence'.

%engine.bnet.CPD = newCPDs;

args = varargin;
nargs = length(args);
for i=1:2:nargs
  switch args{i}
      case 'maximize', engine.maximize = args{i+1};
      case 'clpot', engine.clpot = args{i+1} ;
      case 'seppot', engine.seppot = args{i+1} ;
      case 'bnet', engine.bnet = args{i+1} ;
      case 'CPD', engine.bnet.CPD = args{i+1} ;
  end
end