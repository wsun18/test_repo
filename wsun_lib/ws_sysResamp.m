%% systmatic resampling based on uniformly generated number 
%% Oct.22,2004

function y = wsun_sysResamp(x,ns)

% x is a matrix containing samples, the number in last column 
% is the weight for the sample in the same row.
% ns is the number of samples needed after resampling.

[nr nc] = size(x) ;  % nr:# of row; nc:# of column ;

x(:,nc) = x(:,nc)/sum(x(:,nc)) ; % weight normalizaition

%initialize the CDF
CDF = zeros(nr,1);
CDF(1) = x(1,nc) ;  
for i = 2:nr
    CDF(i) = CDF(i-1) + x(i,nc) ; 
end

% start at bottom of the CDF
i = 1; 
% draw a starting point uStart ~ Uniform(0, 1/numParticles)
uStart = rand(1)*1/ns ;

for j=1:ns
    uCurrent = uStart + (j-1)/ns  ;
    while uCurrent >= CDF(i)
        i = i+1 ;
    end
    y(j,:) = x(i,:) ;    
end

y(:,nc) = 1/ns ;
