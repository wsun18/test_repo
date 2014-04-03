function w = myInd2sub(siz,ndx)
% Based on original built-in 'ind2sub', I modified to always return a row
% vector containing the subscript index for the matrix.

% ORIGINAL 'ind2sub' description:
% IND2SUB Multiple subscripts from linear index.
%   IND2SUB is used to determine the equivalent subscript values
%   corresponding to a given single index into an array.
%
%   [I,J] = IND2SUB(SIZ,IND) returns the arrays I and J containing the
%   equivalent row and column subscripts corresponding to the index
%   matrix IND for a matrix of size SIZ.  
%   For matrices, [I,J] = IND2SUB(SIZE(A),FIND(A>5)) returns the same
%   values as [I,J] = FIND(A>5).
%
%   [I1,I2,I3,...,In] = IND2SUB(SIZ,IND) returns N subscript arrays
%   I1,I2,..,In containing the equivalent N-D array subscripts
%   equivalent to IND for an array of size SIZ.
%
%   Class support for input IND:
%      float: double, single
%
%   See also SUB2IND, FIND.
 
%   Copyright 1984-2011 The MathWorks, Inc. 
%   $Revision: 1.13.4.5 $  $Date: 2011/12/22 18:27:11 $

% nout = max(nargout,1);
% siz = double(siz);
% lensiz = length(siz);
% 
% if lensiz < nout
%     siz = [siz ones(1,nout-lensiz)];
% elseif lensiz > nout
%     siz = [siz(1:nout-1) prod(siz(nout:end))];
% end
% 
% if nout == 2
%     vi = rem(ndx-1, siz(1)) + 1;
%     varargout{2} = (ndx - vi)/siz(1) + 1;
%     varargout{1} = vi;
% else
    
    nout = length(siz) ;
    k = [1 cumprod(siz(1:end-1))];
    for i = nout:-1:1,
        vi = rem(ndx-1, k(i)) + 1;
        vj = (ndx - vi)/k(i) + 1;
        w(i) = vj;
        ndx = vi;
    end
    
    
% end
