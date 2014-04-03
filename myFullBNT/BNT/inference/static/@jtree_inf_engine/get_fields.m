function stt = get_fields(engine, fieldname)
% SET_FIELDS Set the fields for a generic engine
% engine = set_fields(engine, name/value pairs)
%
% e.g., engine = set_fields(engine, 'maximize', 1)

% args = varargin;
% nargs = length(args);

  switch fieldname
      case 'maximize', stt = engine.maximize;
      case 'clpot', stt = engine.clpot ;
      case 'seppot', stt = engine.seppot ;
      case 'bnet', stt = engine.bnet  ;
      case 'preorder', stt = engine.preorder ;
      case 'postorder', stt = engine.postorder ;
      case 'evidence', stt = engine.evidence ;
  end

