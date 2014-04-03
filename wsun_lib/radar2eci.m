function [t x y z] = radar2eci(radar_ini_lon, t, r, azim, ele)

% this function transforms the radar's observations (range, azimuth,
% elevation) to the target's location (x, y, z) in the ECI coordinate

% assumption: radar is located on the equator, 
%                        ie, Latitude 0.0, Altitude 0, only Longitude >=0

% radar_ini_lon : radar's initial longitude in degree ( not radian)
% t: time stamp
% r: range
% azim: azimuth
% ele: elevation


w = 7.2921151e-5 ;  % Earth's rotation speed in rad/sec
Re = 6378137 ;       % Earth's radius in meter
deg2radian = pi/180 ; % degree to radian

theta_lon = radar_ini_lon * deg2radian ; % transfor longitude from degree into radian
theta_g = w * t ;

l = r * cos(ele) ;
if azim > 3*pi/2
    N = l * sin(5*pi/2 - azim) ;    % north
    E = l * cos(5*pi/2 - azim) ;    % east
else
    N = l * sin(pi/2 - azim) ;
    E = l * cos(pi/2 - azim) ;
end    
   
H = r * sin(ele) ;

xp = Re + H ;
yp = E ;

ft = theta_lon + theta_g  ;

[x y] = coor_rot(ft, xp, yp) ;
z = N ;

t = t ;


