
function T = DAC_mysubintval(smallrange, bigrange)
%% This function is to determine if the smallrange is covered by the bigrange.
%  Both smallrange and bigrange are n*2 matrices, in which each row
%  indicates an interval by 2 numbers. Number of rows of smallrange and
%  bigrange have to be equal. 

if size(smallrange,1) ~= size(bigrange,1)
    error('input matrices have to have equal number of rows');
end

if size(smallrange,2) ~= 2
    error('input matrices have to have number of columns as 2') ;
end

if size(bigrange,2) ~= 2
    error('input matrices have to have number of columns as 2') ;
end

for k=1:size(smallrange,1)
    s1 = smallrange(1) ;
    s2 = smallrange(2) ;
    r1 = bigrange(1) ;
    r2 = bigrange(2) ;
    if s1 < r1 || s2 > r2
        T = 0 ;
        return ;
    end    
end

T = 1 ;
