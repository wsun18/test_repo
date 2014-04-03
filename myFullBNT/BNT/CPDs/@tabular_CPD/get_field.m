function val = get_field(CPD, name)
% GET_PARAMS Get the parameters (fields) for a tabular_CPD object
% val = get_params(CPD, name)
%
% The following fields can be accessed
%
% cpt, counts
%
% e.g., CPT = get_params(CPD, 'CPT')

switch name
    case 'CPT',      val = CPD.CPT;
    case 'counts',   val = CPD.counts;
    case 'sizes',    val = CPD.sizes ;
 otherwise,
  error(['invalid argument name ' name]);
end
