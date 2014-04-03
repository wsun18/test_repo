function f = getfield(pot,varargin)

disp('conditional Gaussian potential object');
disp(struct(pot));

strField = varargin{1};
if (length(varargin)==1 && ischar(strField))    
    f = pot.(deblank(strField)); % deblank field name    
    for i=1:length(f)
        %f{i}
        if (strField == 'can')
            tpot = f{i};
            fprintf('\n+++++ can{%d}: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', i);
            display_ghk(tpot,'g');
            display_ghk(tpot,'h');
            display_ghk(tpot,'K');            
        end
    end
    return
else
    error('wrong usage of getfield for potential');    
end

