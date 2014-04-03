function jp = jointprob(p)
% p is a matrix containing original i.i.d. prob. distributions, each column
% is a RV; and each row is for one particular state
% jp is the returned joint prob. 
% -wsun, 8/18/11

nv = size(p,2); 

ns = 2*ones(1,nv) ;
cc = full_combination(ns) ;

N = 2^nv; 
for i=1:N
    tp = p(cc{i,1},1) ;
    for j=2:nv
        tp = tp*p(cc{i,j},j) ;
    end
    jp(i) = tp;
end

jp = jp' ; % make it into a column vector


    