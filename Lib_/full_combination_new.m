function cc = full_combination_new(ns)
% return the complete combination of possible instantiations for interface
% nodes.
% cc is a matrix, with each row containing full instantiations of all
% variables considered.
% Nov.3, 2011

dim = length(ns) ;

%cc = cell(prod(ns), dim) ;

for k=1:dim
    sz = ns(k) ;
    r = prod(ns(1:k-1))  ;
    s = prod(ns(k+1:end))  ;
    m = prod(ns(1:k)) ;
    for i = 1:s
        for n = 1:sz
            a = (i-1)*m + (n-1)*r + 1 ;
            b = (i-1)*m + n*r  ;  
            cc(a:b, k) = n  ;
        end
    end
end

% for j=1:length(ns)
%     b(j) = prod(ns(1:j)) ;
% end
% 
% for i = 1:prod(ns)
%     for j = 1:length(ns)
%         a(i,j) = floor(mod(i+1,b(j+1)) / b(j)) + 1 
%     end
% end
% 
% disp(a)
        







