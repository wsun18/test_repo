function [mpe, pmax, lpe, pmin, domain] = find_mpe_lpe_fromJoint(joint)
% This function finds MPE and LPE from joint distribution, corresponding
% joint states are returned as well. 
% The argument 'joint' is a structure, with fields 'domain', 'sizes', 'T',
% and 'cc'.
% Nov.4, 2011
% -wsun


domain = joint.domain ;

[pmax, mi] = max(joint.T) ;
mpe = joint.cc(mi,:) ;

[pmin, li] = min(joint.T) ;
lpe = joint.cc(li,:) ;


        







