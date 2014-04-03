

function show_bel_gauss(bnet, bel, evidence)

%fprintf('+++++++ Iteration %g : beliefs for all nodes +++++++++\n', niter) ;

cnodes = bnet.cnodes ;

N = length(bel) ;
for i=1:N
    nm = bnet.node_names{i} ; % node name.
    if ~isempty(bel{i})
        if myintersect(i, cnodes)
            fprintf('   %s.bel - mu: [%g], Sigma: [%g] \n', ...
                nm, bel{i}.mu, bel{i}.Sigma) ;            
        else
            nos = bnet.node_sizes(i);
            fprintf('posterior marginal of %s: [%g ', nm, bel{i}(1)) ;        
            for k=2:nos-1
                fprintf('%g ', bel{i}(k)) ;        
            end
            fprintf('%g] \n', bel{i}(end)) ;            
        end
    else 
        fprintf('   %s.bel - observed: %g\n', nm, evidence{i}) ;
    end
end

fprintf('   *\n') ;



