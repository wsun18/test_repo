

function [x y] = coor_rot(theta, xp, yp) 

% H = [ cos(theta)  -sin(theta)
%          sin(theta)    cos(theta) ]

x = xp*cos(theta) - yp*sin(theta) ;

y = xp*sin(theta) + yp*cos(theta) ;


