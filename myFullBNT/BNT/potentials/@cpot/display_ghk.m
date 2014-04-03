function display_ghk(pot,varargin)

%disp('canonical potential object');
%disp(struct(pot));

strField = varargin{1};
if (length(varargin)==1 && ischar(strField))    
    fprintf('\n%s:--- ', strField); 
    pot.(deblank(strField)) % deblank field name    
%     for i=1:length(f)
%         f{i}
%     end
    return
else
    error('wrong usage of getfield for potential');    
end
