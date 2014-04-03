
function val = get_message(engine)
% GET_MESSAGE Get the messages saved in engine object
% written by wsun at 04/16/2006

%
% The following fields can be accessed
%
% mean       - mu(:,i) is the mean given Q=i
% cov        - Sigma(:,:,i) is the covariance given Q=i 
% weights    - W(:,:,i) is the regression matrix given Q=i 
%
% e.g., mean = get_params(CPD, 'mean')
% 
% switch name
%  case 'mean',      val = CPD.mean;
%  case 'cov',       val = CPD.cov;
%  case 'weights',   val = CPD.weights;
%  otherwise,
%   error(['invalid argument name ' name]);


val = engine.msg ;