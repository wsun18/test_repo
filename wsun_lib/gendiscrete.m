
function dsp = gendiscrete(ddist)
% 'gendiscrete' return one of finite states a discrete 
% random variable has according to its mass function 'ddist'

% 'ddist' is a row vector saves the probabilities for all states
% sum(ddist) should be 1
% as an example, ddist=[.2 .1 .3 .3 .1]

u = rand ;
cf = 0 ;
for i=1:length(ddist)
    cf = cf + ddist(i) ;
    if u <= cf
        dsp = i ;
        return ;
    end
end
    