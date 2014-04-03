function T = prod_CPT_and_pi_msgs(CPD, n, ps, msgs, except)
% PROD_CPT_AND_PI_MSGS Multiply the CPD and all the pi messages 
% from parents, perhaps excepting one
% T = prod_CPT_and_pi_msgs(CPD, n, ps, msgs, except)

if nargin < 5, except = -1; end

dom = [ps n];  % the index of parents node and the node itself
%ns = sparse(1, max(dom));
ns = zeros(1, max(dom));
CPT = CPD_to_CPT(CPD);
ns(dom) = mysize(CPT);  % node size of parents node and the node itself
T = dpot(dom, ns(dom), CPT);
for i=1:length(ps)
  p = ps(i);
  if p ~= except
      tpp = dpot(p, ns(p), msgs{n}.pi_from_parent{i}) ;
      T = multiply_by_pot(T, tpp) ;      
      %T = multiply_by_pot(T, dpot(p, ns(p), msgs{n}.pi_from_parent{i}));
  end
end         
