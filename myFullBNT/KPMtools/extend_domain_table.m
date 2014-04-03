function B = extend_domain_table(A, smalldom, smallsz, bigdom, bigsz)
% EXTEND_DOMAIN_TABLE Expand an array so it has the desired size.
% B = extend_domain_table(A, smalldom, smallsz, bigdom, bigsz)
%
% A is the array with domain smalldom and sizes smallsz.
% bigdom is the desired domain, with sizes bigsz.
%
% Example:
% smalldom = [1 3], smallsz = [2 4], bigdom = [1 2 3 4], bigsz = [2 1 4 5],
% so B(i,j,k,l) = A(i,k) for i in 1:2, j in 1:1, k in 1:4, l in 1:5

if isequal(size(A), [1 1]) % a scalar
  B = A * myones(bigsz);  %% size should be consistent --wsun, 12/17/2012.
  return;
end

% map = find_equiv_posns(smalldom(k), bigdom) ; 
% sz(map) = smallsz;
% B = myreshape(A, sz);
%%%%%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 11/06/2013 !!!!!!!!!!!!!
% bug fixed by wsun: smalldom is not necessarily sorted. If it is not
% sorted, find_equiv_posns may return wrong position index. 
% and by simply reshaping the original smallT, it may not give you the
% right matrix. Example of taking two-dimensional matrix into the reverse
% order can verify it. 

% % suppose A with dom [3 8] is 
% 
%    33.0000   21.0000    9.0000
%     0.3200    1.5000    6.9000
%     
%  obviously, original size is [2 3]. If we like to construct a matrix with 
%  domain [8 3], it should be simply the prime of the original matrix. But 
%  if you reshape(A, [3 2]), you get something not you want. 



map = [] ;
for k=1:length(smalldom)
    map = [map find_equiv_posns(smalldom(k), bigdom)] ;
end
sz = ones(1, length(bigdom));
sz(map) = smallsz;


h_cc = full_combination_new(sz) ;
noi = size(h_cc,1); % number of instances

for i=1:noi
    instance = h_cc(i,:);   
    B(i) = A(find_linearIndex_from_mat(smallsz,instance(map)));    
end

B = myreshape(B, sz); % add dimensions for the stuff not in A
sz = bigsz;
sz(map) = 1; % don't replicate along A's dimensions
B = myrepmat(B, sz(:)');
                           
