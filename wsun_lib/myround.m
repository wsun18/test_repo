function r = myround(n)
% disregard rounding errors for decimal numbers.

T = 10000 ;
r = round(n*T)/T ;