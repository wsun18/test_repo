function bnet = mk_Hierarchical_deterministicCPT()


N = 17;

dag = zeros(N);
for i = 1:5
    switch i
        case 1
            for j = i+1:1:i+4
                dag(i,j) = 1;
            end
        case {2,3,4,5}
            for j = 3*i:1:3*i+2
                dag(i,j) = 1;
            end
    end
end

node_names = cell(1,N);
node_names{1} = 'Y_2014';
for i = 2:5
    node_names{i} = strcat('Q_', int2str(i-1));
end
for i = 6:17
    node_names{i} = strcat('M_', int2str(i-5));
end

% BGobj = biograph(dag,node_names);
% view(BGobj);

arity = 2;
ns = arity*ones(1,N);

bnet = mk_bnet(dag,ns,'names',node_names);

bnet.CPD{1} = tabular_CPD(bnet, 1, [0.5, 0.5]);

% 2014|P(Q_i=F)|P(Q_i=T)
% F   |1       |0
% T   |0.75    |0.25
for i = 2:5
    bnet.CPD{i} = tabular_CPD(bnet, i, [1, 0.75, 0, 0.25]);
end

% Q|P(M_i=F)|P(M_i=T)
% F|1       |0
% T|2/3     |1/3
for i = 6:17
    bnet.CPD{i} = tabular_CPD(bnet, i, [1, 2/3, 0, 1/3]);
end
