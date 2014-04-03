function y = mygsamp_node(CPD, pev)
% written on Jan.24, 2007 --- WSUN
%
% pev{i} is the value of the i'th parent (if there are any parents)
% y is the sampled value (a scalar or vector)


if nargin < 2, pev=[] ; end

if isempty(CPD.cps)
    y = CPD.mu + sqrt(CPD.cov) * randn ;
else
    func = CPD.function ;
    var_names = CPD.variables(1:end-1) ;
    tmu = CPD.mean + subs(func, var_names, pev) ;
    y = tmu + sqrt(CPD.cov) * randn ;
end
