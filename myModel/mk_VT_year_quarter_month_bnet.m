function bnet = mk_deterministicHierarchical_vt_2()


N = 22;
dag = zeros(N);
dag(1,2) = 1;
for i = 3:6
    dag(2,i) = 1;
end
for i = 3:6
    dag(i,i+4) = 1;
end
for i = 11:13
    dag(7,i) = 1;
end
for i = 14:16
    dag(8,i) = 1;
end
for i = 17:19
    dag(9,i) = 1;
end
for i = 20:22
    dag(10,i) = 1;
end

node_names = cell(1,N);
node_names{1} = 'Y_2014';
node_names{2} = 'CQ';
for i = 3:6
    node_names{i} = strcat('Q_', int2str(i-2));
end
for i = 7:10
    node_names{i} = strcat('CQ_', int2str(i-6));
end
for i = 11:22
    node_names{i} = strcat('M_', int2str(i-10));
end

BGobj = biograph(dag,node_names);
view(BGobj);

arity = 2;
ns = arity*ones(1,N);
ns(2) = 5;
for i = 7:10
    ns(i) = 4;
end

bnet = mk_bnet(dag,ns,'names',node_names);

bnet.CPD{1} = tabular_CPD(bnet, 1, [0.5, 0.5]);

% 2014|None|Q1   |Q2   |Q3   |Q4
% F   |1   |0    |0    |0    |0
% T   |0   |0.25 |0.25 |0.25 |0.25 
bnet.CPD{2} = tabular_CPD(bnet, 2, [1, 0, 0, 0.25, 0, 0.25, 0, 0.25, 0, 0.25]);

% CQ   |F |T
% None |1 |0   
% Q1   |0 |1
% Q2   |1 |0
% Q3   |1 |0
% Q4   |1 |0
bnet.CPD{3} = tabular_CPD(bnet, 3, [1, 0, 1, 1, 1, 0, 1, 0, 0, 0]);

% CQ   |F |T
% None |1 |0    
% Q1   |1 |0
% Q2   |0 |1
% Q3   |1 |0
% Q4   |1 |0
bnet.CPD{4} = tabular_CPD(bnet, 4, [1, 1, 0, 1, 1, 0, 0, 1, 0, 0]);

% CQ   |F |T
% None |1 |0    
% Q1   |1 |0
% Q2   |1 |0
% Q3   |0 |1
% Q4   |1 |0
bnet.CPD{5} = tabular_CPD(bnet, 5, [1, 1, 1, 0, 1, 0, 0, 0, 1, 0]);

% CQ   |F |T
% None |1 |0    
% Q1   |1 |0
% Q2   |1 |0
% Q3   |1 |0
% Q4   |0 |1
bnet.CPD{6} = tabular_CPD(bnet, 6, [1, 1, 1, 1, 0, 0, 0, 0, 0, 1]);

% Qi|None|M1   |M2   |M3
% F |1   |0    |0    |0    
% T |0   |1/3  |1/3  |1/3
for i = 7:10
    bnet.CPD{i} = tabular_CPD(bnet, i, [1, 0, 0, 1/3, 0, 1/3, 0, 1/3]);
end

% CQ1  |F |T
% None |1 |0  
% M1   |0 |1
% M2   |1 |0
% M3   |1 |0
bnet.CPD{11} = tabular_CPD(bnet, 11, [1, 0, 1, 1, 0, 1, 0, 0]);

% CQ1  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |0 |1
% M3   |1 |0
bnet.CPD{12} = tabular_CPD(bnet, 12, [1, 1, 0, 1, 0, 0, 1, 0]);

% CQ1  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |1 |0
% M3   |0 |1
bnet.CPD{13} = tabular_CPD(bnet, 13, [1, 1, 1, 0, 0, 0, 0, 1]);

% CQ2  |F |T
% None |1 |0  
% M1   |0 |1
% M2   |1 |0
% M3   |1 |0
bnet.CPD{14} = tabular_CPD(bnet, 14, [1, 0, 1, 1, 0, 1, 0, 0]);

% CQ2  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |0 |1
% M3   |1 |0
bnet.CPD{15} = tabular_CPD(bnet, 15, [1, 1, 0, 1, 0, 0, 1, 0]);

% CQ2  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |1 |0
% M3   |0 |1
bnet.CPD{16} = tabular_CPD(bnet, 16, [1, 1, 1, 0, 0, 0, 0, 1]);

% CQ3  |F |T
% None |1 |0  
% M1   |0 |1
% M2   |1 |0
% M3   |1 |0
bnet.CPD{17} = tabular_CPD(bnet, 17, [1, 0, 1, 1, 0, 1, 0, 0]);

% CQ3  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |0 |1
% M3   |1 |0
bnet.CPD{18} = tabular_CPD(bnet, 18, [1, 1, 0, 1, 0, 0, 1, 0]);

% CQ3  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |1 |0
% M3   |0 |1
bnet.CPD{19} = tabular_CPD(bnet, 19, [1, 1, 1, 0, 0, 0, 0, 1]);

% CQ4  |F |T
% None |1 |0  
% M1   |0 |1
% M2   |1 |0
% M3   |1 |0
bnet.CPD{20} = tabular_CPD(bnet, 20, [1, 0, 1, 1, 0, 1, 0, 0]);

% CQ4  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |0 |1
% M3   |1 |0
bnet.CPD{21} = tabular_CPD(bnet, 21, [1, 1, 0, 1, 0, 0, 1, 0]);

% CQ4  |F |T
% None |1 |0    
% M1   |1 |0
% M2   |1 |0
% M3   |0 |1
bnet.CPD{22} = tabular_CPD(bnet, 22, [1, 1, 1, 0, 0, 0, 0, 1]);