function smallT = marg_table(bigT, bigdom, bigsz, onto, moption)
% MARG_TABLE Marginalize a table
% smallT = marg_table(bigT, bigdom, bigsz, onto, maximize)


%if nargin < 5, maximize = 0; end
if nargin < 5, moption = 'sum'; end
% modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
% 'moption' means marginization option. 
% -wsun

smallT = myreshape(bigT, bigsz); % make sure it is a multi-dim array
sum_over = mysetdiff(bigdom, onto);
ndx = find_equiv_posns(sum_over, bigdom);
% if maximize
%   for i=1:length(ndx)
%     smallT = max(smallT, [], ndx(i));
%   end
% else
%   for i=1:length(ndx)
%     smallT = sum(smallT, ndx(i));
%   end
% end
% modified on 10/28/11, to allow to choose sum-,max-,or min-propagation,
% 'moption' means marginization option. 
% -wsun
switch moption
    case 'sum', 
        for i=1:length(ndx)
            smallT = sum(smallT, ndx(i));
        end
    case 'max', 
        for i=1:length(ndx)
            smallT = max(smallT, [], ndx(i));
        end
    case 'min',        
        smallT(find(smallT==0)) = 1.1 ;
        for i=1:length(ndx)            
            smallT = min(smallT, [], ndx(i));
            %op_smallT = max(1-smallT,[],ndx(i));
            %smallT = 1 - op_smallT ;
        end
        smallT(find(smallT==1.1)) = 0 ;
    otherwise,
        error('no marginilization options');
end

ns = zeros(1, max(bigdom));
%ns(bigdom) = mysize(bigT); % ignores trailing dimensions of size 1
ns(bigdom) = bigsz;

smallT = squeeze(smallT); % remove all dimensions of size 1
ssz = ns(onto) ;
if length(find(ssz>1)) > 1
    smallT = myreshape(smallT, ssz(find(ssz>1))); % put back relevant dims of size 1
else
    smallT = myreshape(smallT, [ssz(find(ssz>1)) 1]); 
end
    
