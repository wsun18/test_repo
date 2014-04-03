function [bf_jp bf_score bf_time] = brute_forece_mkedit_lazy(x,bf_score,Targid,targ,tprob,Assmid,assm) ;
% This is to compute the joint probability distribution over all variables
% after making an edit, based on current 'bf_jp'
% -wsun, 4/12/2012

t0 = cputime ;
ns = size(x) ;

% dag = test_bnet.dag ;
% ns = test_bnet.node_sizes ;
% N = length(ns) ;
% node_names = test_bnet.node_names ;
% hcc = full_combination_new(ns) ;
% 
% TargId = findindex4stringcell(node_names, Targ) ;
% if ~isempty(Assm)
%     for k=1:length(Assm)
%         AssmId = findindex4stringcell(node_names, Assm{k}) ;
%     end
% end
% x = reshape(bf_jp,ns) ;
P_Targ = calc_conditionalDist_from_joint(x,Targid,Assmid,assm) ;

Targ_ns = ns(Targid) ;
Q_Targ = zeros(1,Targ_ns) ; %This is Q(Targ|Assm=assm)
nnm = 1 - P_Targ(targ) ; % normalization constant for normalizing probabilities on other states
for k=1:Targ_ns
    if k == targ
        Q_Targ(targ) = tprob ;        
        %r(k) = tprob/P_Targ(targ) ;
        r1 = tprob/P_Targ(targ) ;
    else        
        Q_Targ(k) = (1-tprob)*P_Targ(k)/nnm ;
        %r(k) = Q_Targ(k)/P_Targ(k) ;
    end
end
r2 = (1-tprob)/nnm ;

hcc = full_combination_new(ns) ;
b = 10/log(100) ;
for j=1:size(hcc,1)
   instance = hcc(j,:) ;
   if instance(Assmid) == assm 
       if instance(Targid) == targ
           bf_jp(j) = r1*x(j) ;
           bf_score(j) = bf_score(j) + b*log(bf_jp(j)/x(j)) ;
       else
           bf_jp(j) = r2*x(j) ;
           bf_score(j) = bf_score(j) + b*log(bf_jp(j)/x(j)) ;
       end
   else
       bf_jp(j) = x(j) ;
   end
end

bf_time = cputime - t0 ;


%bf_score = bf_score + b*log(bf_jp'./x(:)) ;
