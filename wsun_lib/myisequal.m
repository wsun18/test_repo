function boo = myisequal(A,B)
% Assumption: A, B must be vectors/arrays, but it does not matter to be
% column array or row array
% --wsun, 12/11/2012

if length(A) ~= length(B)
    boo = 0 ;
    return ;
end

for i=1:length(A)
    if A(i) ~= B(i)
        boo = 0 ;
        return ;
    end    
end

boo = 1 ;