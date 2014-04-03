function B = extend_size_table(smallT,smallsz,bigsz,orig_dom,ext_dom)
% This function is to extend the current table to a bigger size, assuming
% the domain is still the same. 'ext_dom' is the dimension that we need to
% extend the size, but itself is part of the 'orig_dom'. 

% -wsun, 5/9/13


map = find_equiv_posns(ext_dom, orig_dom);
sz = ones(1, length(orig_dom));
sz(map) = bigsz(map);

B = myrepmat(smallT, sz);
                           
