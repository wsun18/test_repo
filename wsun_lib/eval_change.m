
function change = eval_change(msg_type, bel, old_bel)

switch msg_type
    case 'd'
        change = sum(abs(bel - old_bel));
    case 'gm'
        change = max(abs(bel.mu - old_bel.mu),abs(bel.Sigma - old_bel.Sigma)) ;
    otherwise
        error('msg_type wrong, must be either d or gm');
end