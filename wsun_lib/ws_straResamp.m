%% deterministic resampling based on weight only
%% Oct.22,2004

function y = wsunResamp(x,sn)

% x is a matrix containing samples, the number in last column 
% is the weight for the sample in the same row.
% sn is the number of samples needed after resampling.

[nr nc] = size(x) ;
x(:,nc) = x(:,nc)/sum(x(:,nc)) ; % weight normalizaition

x = sortrows(x,nc) ;

x(:,nc) = round(x(:,nc)*sn) ;

k = 1 ;
for i=nr:-1:1
    nchild = x(i,nc) ; % determine number of child for the current sample.
    m1 = ones(nchild,1) ;  % artificial coefficient column vector
    
    if k+nchild-1 > sn
        m1 = ones(sn-k+1,1) ;
        y(k:sn,:) = m1*x(i,:) ;
        break ;
    else
        y(k:k+nchild-1,:) = m1*x(i,:) ;
    end
    
    k = k+nchild ;
    
end

y(:,nc) = 1/sn ;
    
    



