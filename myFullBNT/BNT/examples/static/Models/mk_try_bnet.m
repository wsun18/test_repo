function bnet = mk_try_bnet(CPD_type)
 % written on Jan.18, 2007
 % in the purpose of coding Gaussian_CPD for CPD.function

if nargin == 0, CPD_type = 'orig'; end

A = 1;
B = 2;
H = 3;

n = 3;
dag = zeros(n);
dag([A B], H) = 1;

ns = ones(1,n) ;
if strcmp(CPD_type, 'gauss')
  dnodes = [];
else
  dnodes = 1:n;
end
bnet = mk_bnet(dag, ns, 'discrete', dnodes);

switch CPD_type
  case 'orig',     
      for i=1:n
          bnet.CPD{i} = tabular_CPD(bnet, i) ;
      end
  case 'gauss',
      for i=1:n
          bnet.CPD{i} = gaussian_CPD(bnet, i) ;
      end
end

  
  
