
function tf = isin(s, vt)
% check if s is in vector vt
% true, return 1; false, return 0 
 
 for i=1:length(vt)
     val = vt(i) ;
     if s==val
         tf=1 ;
         return ;
     end
 end
 
 tf = 0 ;