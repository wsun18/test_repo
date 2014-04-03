% test how dynamic asset model works

clear
clear all
clear classes %whenever you change a class definition, you need to call this.
close all
home
fprintf('\n')
disp('====================================')
disp('Prob. and Asset Updating using BN for Prediction Market')

myHome = '/Users/wsun/wsunCloud/Dropbox/myResearch/matlab/DAC_';
addpath(fullfile(myHome, 'myModel')) ;
addpath(fullfile(myHome, 'wsun_lib')) ;
addpath(fullfile(myHome, 'Lib_')) ;
addpath(fullfile(myHome, 'BruteForceFunc_')) ;

global S b log_base vList vSizes;
S=100; b=100; log_base=2; 
% vList = {'N28','N3','N34','N20','N7','N6','N8','N25','N10','N33'} ;
vList = {} ;
vSizes = [] ;

%%%%% ============ prob. and asset initialization
thh1 = .001 ; % threshold for probability
thh2 = .1 ; % threshold for asset
ResQ = {} ; % initialize resolved question list
resQ = [] ; % initialize resolved states vector
% AddQ = {} ; % initialize added question list

%%%%% ============ user initialization
nofu = 10 ;
user = cell(1,nofu) ;

load Data_/crossTestNetStructure ;
dag = bn20tw5_bn20tw10_dag ; % the DAG matrix for the two disconnected networks.

S = 100 ;
nofu = 10 ;
user = cell(1,nofu) ;

fin = fopen('Data_/121114_seed1352944836518.txt', 'r') ;
fout = fopen('Data_/Y2_userAssetTracking.txt','w') ;

ncc = [0 0 0 0]; 
cnt = 1 ;
while ~feof(fin)
    tic    
    tline = fgetl(fin) ;
    if strcmp(tline,'Gch_comingSoon999')
        init = 1 ;
        fprintf('**** Cross test auto comparison starts, hold on!\n') ;        
        fprintf(fout,'**** Cross test auto comparison starts, hold on!\n') ;  
    elseif (strcmp(tline, '###===')) ;
        init = 0 ;   cnt = cnt + 1 ; % new iteration        
    end
    binf = sscanf(fgetl(fin),'%i %g') ;
    assert(length(binf) == 7) ; % basic information containting 7 numbers
    iteNum = binf(1) + 1 ; % java starts counting from 0
    
%     if (iteNum > 1085)
%         fprintf('Iteration # is %i\n',iteNum) ;
%         fprintf(fout, 'Iteration # is %i\n', iteNum) ;
%         %break ;
%     end
    
    assert(iteNum == cnt) ;
    addVar = binf(2) ;
    cu = binf(3) + 1 ; % java starts counting from 0
    addCash = binf(4) ;    
    tradeType = binf(5) ; % 0 means regular trade, positive # means # balance trade
    resolInd = binf(6) ; % either 0 or 1    
    revertInd = binf(7) ; % either 0 or 1
    
   
    if (addVar > 0) 
        varLine1 = fgetl(fin) ;
        varName = regexp(varLine1,'\w*N\w*','match') ;
        assert(addVar == length(varName)) ;        
        varLine2 = fgetl(fin) ;
        varSize = sscanf(varLine2,'%i') ; 
        varSize = reshape(varSize,[1 length(varSize)]) ;
        assert(length(varName) == length(varSize)) ; 
%         AddQ(end+1:end+length(varName)) = varName ;  
        if (init == 1) 
            %%%%% ============ model initialization
            model.node_names = varName ;
            model.sizes = reshape(varSize,[1 length(varSize)]) ;
            jp_current = (1/prod(model.sizes))*ones(prod(model.sizes),1) ;
        else
            add_model.node_names = varName ;
            add_model.sizes = reshape(varSize,[1 length(varSize)]) ;
            [model, jp_current, user] = bf_prob_asset_add_model(user,jp_current,model,add_model) ;            
        end
        vList = [vList varName] ;
        vSizes = [vSizes varSize] ;
    end
    if isempty(user{cu})
        user{cu}.manna = addCash ;
        user{cu}.base = S + addCash ; % newly added field, -wsun, 9/23/2013
        user{cu}.cash = S + addCash ;
        user{cu}.asset = user{cu}.cash*ones(prod(model.sizes),1) ;
        dac.base = S + addCash; dac.Q_list = {}; dac.ns = []; dac.abc={}; 
        user{cu}.dac = dac ;
    elseif (addCash > 0)
        user{cu}.manna = user{cu}.manna + addCash ;
        user{cu}.base = user{cu}.base + addCash ;
        user{cu}.cash = user{cu}.cash + addCash ;  
        user{cu}.asset = user{cu}.asset + addCash ;  
        user{cu}.dac.base = user{cu}.dac.base + addCash ;
    end    
    
    if (tradeType == 0) % regular trade
        Targ = {} ; targ = [] ; Assm = {} ; assm = [] ;  A_sz=[] ;% clear up edit variables for each iteration
        eline1 = fgetl(fin) ;
        spInd = regexp(eline1,'\s') ;  % space indices, suppose to have only two numbers
        assert(length(spInd) == 2) ;   
        Targ{1} = eline1(1:spInd(1)-1) ;
        targ = str2num(eline1(spInd(1)+1)) + 1 ; % java starts counting from 0 
        indTarg = findindex4stringcell(vList, Targ);
        T_sz = vSizes(indTarg) ;
        comboInd = str2num(eline1(spInd(2)+1)) ;
        if ( comboInd > 0) % combo edit, read in Assumption
            eline2 = fgetl(fin) ;
            Assm = regexp(eline2,'\w*N\w*','match') ;            
            assert(comboInd == length(Assm)) ;            
            eline3 = fgetl(fin) ;
            assm = sscanf(eline3,'%i') + 1 ; % java starts counting from 0
            assm = assm(:)' ; % has to be in row vector format, wsun, 11/5/13.
            
            indAssm = [] ;
            for k=1:length(Assm)
                indAssm = [indAssm findindex4stringcell(vList, Assm{k})] ;
            end
            A_sz = vSizes(indAssm) ;
        end
        edtbound = sscanf(fgetl(fin),'%g') ;
        [lbd, ubd] = bf_find_edit_limit(model,jp_current,user{cu},Targ,targ,Assm,assm) ;
        %fprintf('*** edit limit are [%g, %g] \n', lbd, ubd) ;
        assert(sum(abs([lbd ubd]' - edtbound)) < thh1) ;
        cProb = bf_find_currProb(model,jp_current,Targ,Assm,assm) ;
        tProb = sscanf(fgetl(fin),'%g') ;  
        if ((tProb(targ) - lbd) < .02) 
            ncc(1) = ncc(1) + 1 ; % tracing number of regular trades near lbd
        end
        if ((ubd - tProb(targ)) < .02)
            ncc(2) = ncc(2) + 1 ; % tracing number of regular trades near ubd
        end
        assert(abs(sum(tProb) - 1) < .00001) ;
        
%         if iteNum==100
%             disp('debug') ;
%         end
%         disp(cu) ;
        if iteNum==96
            disp('debug') ;
            disp(cu) ;
        end
        user{cu}.dac = DAC_updateUserAssetBlocks(user{cu}.dac,cProb,tProb,Targ,T_sz,Assm,assm,A_sz) ; %-wsun,11/6/13
                
        [user{cu}, jp_current] = bf_makeTrade(model,user{cu},jp_current,Targ,tProb,Assm,assm) ;       
        
        marg = bf_find_marg(model,jp_current) ;
    else
        ncc(3) = ncc(3) + 1 ; % tracing number of balance trades
        for m=1:tradeType % balance trade
            Targ = {} ; targ = [] ; Assm = {} ; assm = [] ; A_sz=[]; % clear up edit variables for each iteration
            eline1 = fgetl(fin) ;
            spInd = regexp(eline1,'\s') ;  % space indices, suppose to have only two numbers
            assert(length(spInd) == 2) ;   
            Targ{1} = eline1(1:spInd(1)-1) ;
            targ = str2num(eline1(spInd(1)+1)) + 1 ; % java starts counting from 0 
            indTarg = findindex4stringcell(vList, Targ);
            T_sz = vSizes(indTarg) ;
            comboInd = str2num(eline1(spInd(2)+1)) ;
            if ( comboInd > 0) % combo edit, read in Assumption
                eline2 = fgetl(fin) ;
                Assm = regexp(eline2,'\w*N\w*','match') ;            
                assert(comboInd == length(Assm)) ;            
                eline3 = fgetl(fin) ;
                assm = sscanf(eline3,'%i') + 1 ; % java starts counting from 0 
                assm = assm(:)' ; % has to be in row vector format, wsun, 11/5/13.
                
                indAssm = [] ;
                for k=1:length(Assm)
                    indAssm = [indAssm findindex4stringcell(vList, Assm{k})] ;
                end
                A_sz = vSizes(indAssm) ;
            end           
            tProb = sscanf(fgetl(fin),'%g') ; 
            assert(abs(sum(tProb) - 1) < .00001) ;
            cProb = bf_find_currProb(model,jp_current,Targ,Assm,assm) ;
            
            user{cu}.dac = DAC_updateUserAssetBlocks(user{cu}.dac,cProb,tProb,Targ,T_sz,Assm,assm,A_sz) ; %-wsun,9/24/13
            
            [user{cu}, jp_current] = bf_makeTrade(model,user{cu},jp_current,Targ,tProb,Assm,assm) ;             
        end 
        marg = bf_find_marg(model,jp_current) ; %update all marginals.
    end
    
    if (cu==3)        
        if strcmp(Targ{1},'N5') || ~isempty(find(strcmp(Assm,'N5'), 1))
            fprintf('user 3 activity. iteration %i\n', iteNum) ;
        end
    end
    
    user = bf_update_scoreEV(model,user,jp_current) ; % update all users' scoreEV
    
    for j=1:length(model.node_names)
        margline = fgetl(fin) ; 
        spMargInd = regexp(margline,'\s') ; % suppose to have only one number
        assert(length(spMargInd)==1) ;
        indVar = findindex4stringcell(model.node_names, margline(1:spMargInd(1)-1)) ;
        assert(str2num(margline(spMargInd(1)+1)) == model.sizes(indVar)) ;
        ME_marg{indVar} = sscanf(fgetl(fin),'%g') ;
        assert(sum(abs(marg{indVar} - ME_marg{indVar})) < thh1) ;
    end
    
    activeUser = find(~isemptycell(user)) ;
    for k=1:length(activeUser)
        userinfo = sscanf(fgetl(fin),'%i %g %g') ;
        assert(length(userinfo) == 3) ;
        userId = userinfo(1) + 1 ; % java starts counting from 0 
        userScoreEV = userinfo(2) ;
        userCash = userinfo(3) ;
        
        assert(mysubset(userId,activeUser)) ;
        userIndex = find(activeUser==userId) ;
        assert(length(userIndex) == 1) ; % make sure userId is unique in active user list
        uInd = activeUser(userIndex) ;
        assert(abs(user{uInd}.scoreEV - userScoreEV) < thh2); 
        assert(abs(user{uInd}.cash - userCash) < thh2); 
        
%         if iteNum==96
%             disp('debug') ;
%             disp(uInd) ;
%             if uInd == 3
%                 disp('debug') ;
%             end
%         end
        
        DAC_cash = DAC_find_cash(user{uInd}.dac) ;
        assert(abs(DAC_cash - userCash) < thh2) ;
    end
    
    if (resolInd > 0) % Resolving questions
        ncc(4) = ncc(4) + 1 ; % tracing number of times to resolve questions
        RVar = regexp(fgetl(fin),'\w*N\w*','match') ;  
        ResQ(end+1:end+length(RVar)) = RVar ;        
        rState = sscanf(fgetl(fin),'%i') + 1 ; % java starts counting from 0 
        resQ(end+1:end+length(rState)) = rState ; % tracing resolved states         
        
                
        [model, jp_temp, user_temp] = bf_prob_asset_resolve_model(user,jp_current,model,RVar,rState) ;        
        clear user jp_current ;
        user = user_temp; jp_current = jp_temp ;
        clear user_temp jp_temp ;                     
        marg = bf_find_marg(model,jp_current) ; %update all marginals.
        
        % update all active users' asset blocks. 
        activeUser = find(~isemptycell(user)) ;
        for k=1:length(activeUser)
            uInd = activeUser(k) ;           

%             if iteNum==44
%                 disp('debug') ;
%             end
            disp(uInd) ;
            user{uInd}.dac = DAC_updateUserAssetBlocks_Resolving(user{uInd}.dac,RVar,rState); % -wsun, 11/6/13.
        end        
        
        for j=1:length(model.node_names)
            margline = fgetl(fin) ; 
            spMargInd = regexp(margline,'\s') ; % suppose to have only one number
            assert(length(spMargInd)==1) ;
            indVar = findindex4stringcell(model.node_names, margline(1:spMargInd(1)-1)) ;
            assert(str2num(margline(spMargInd(1)+1)) == model.sizes(indVar)) ;
            ME_marg{indVar} = sscanf(fgetl(fin),'%g') ;
            assert(sum(abs(marg{indVar} - ME_marg{indVar})) < thh1) ;
        end
        
        
        for k=1:length(activeUser)
            userinfo = sscanf(fgetl(fin),'%i %g %g') ;
            assert(length(userinfo) == 3) ;
            userId = userinfo(1) + 1 ; % java starts counting from 0 
            userScoreEV = userinfo(2) ;
            userCash = userinfo(3) ;
            assert(mysubset(userId,activeUser)) ;
            userIndex = find(activeUser==userId) ;
            assert(length(userIndex) == 1) ; % make sure userId is unique in active user list
            uInd = activeUser(userIndex) ;
            
            assert(abs(user{uInd}.scoreEV - userScoreEV) < thh2); 
            assert(abs(user{uInd}.cash - userCash) < thh2); 
            
            DAC_cash = DAC_find_cash(user{uInd}.dac) ;
            assert(abs(DAC_cash - userCash) < thh2) ;
        end
    end
    
%     if (revertInd > 0) % reverting trade
%         ncc(5) = ncc(5) + 1 ; % tracing number of times to revert trade
%         rIteNum = sscanf(fgetl(fin),'%i') + 1 ;
%         activeUser = find(~isemptycell(user)) ;
%         temp_user = user ;
%         if rIteNum > 1
%             user = tradeHist{rIteNum-1}.user ;
%             temp1_model = tradeHist{rIteNum-1}.model ;            
%             rRVar = intersect(temp1_model.node_names, ResQ) ;
%             temp2_model.node_names = setdiff(temp1_model.node_names,rRVar) ;            
%             if ~isempty(rRVar)
%                 indRVar = findindex4stringcell(ResQ,rRVar) ;
%                 rrState = resQ(indRVar) ;
%             end
%             for i=1:length(activeUser)
%                 uInd = activeUser(i) ; 
%                 if ~isempty(user{uInd})
%                     if ~isempty(rRVar)
%                         user{uInd}.asset = bf_asset_resolve_model(user{uInd}.asset,temp1_model,rRVar,rrState) ;
%                         user{uInd}.cash = min(user{uInd}.asset) ;
%                     end
%                     user{uInd}.asset = bf_asset_extend_model(user{uInd}.asset,temp2_model,model) ;
%                     manna_diff = temp_user{uInd}.manna - user{uInd}.manna ;
%                     user{uInd}.manna = user{uInd}.manna + manna_diff ;
%                     user{uInd}.cash = user{uInd}.cash + manna_diff ;
%                     user{uInd}.asset = user{uInd}.asset + manna_diff ;
%                     user{uInd}.scoreEV = bf_scoreEV(model,jp_current,user{uInd}.asset) ; 
%                 else
%                     user{uInd}.manna = temp_user{uInd}.manna ;
%                     user{uInd}.cash = S + user{uInd}.manna ;
%                     user{uInd}.asset = user{uInd}.cash*ones(prod(model.sizes),1) ;                
%                     user{uInd}.scoreEV = user{uInd}.cash ;
%                     user{uInd}.tHist = {} ; 
%                 end                               
%             end
%         else            
%             user = cell(1,10) ;
%             for i=1:length(activeUser)
%                 uInd = activeUser(i) ;                
%                 user{uInd}.manna = temp_user{uInd}.manna ;
%                 user{uInd}.cash = S + user{uInd}.manna ;
%                 user{uInd}.asset = user{uInd}.cash*ones(prod(model.sizes),1) ;                
%                 user{uInd}.scoreEV = user{uInd}.cash ;
%                 user{uInd}.tHist = {} ;
%             end            
%         end        
%         for k=1:length(activeUser)
%             userinfo = sscanf(fgetl(fin),'%i %g %g') ;
%             assert(length(userinfo) == 3) ;
%             userId = userinfo(1) + 1 ;
%             userScoreEV = userinfo(2) ;
%             userCash = userinfo(3) ;
%             assert(mysubset(userId,activeUser)) ;
%             userIndex = find(activeUser==userId) ;
%             assert(length(userIndex) == 1) ; % make sure userId is unique in active user list
%             uInd = activeUser(userIndex) ;
%             assert(abs(user{uInd}.scoreEV - userScoreEV) < thh2); 
%             assert(abs(user{uInd}.cash - userCash) < thh2); 
%         end
%         for j=1:length(model.node_names)
%             margline = fgetl(fin) ;        
%             indVar = findindex4stringcell(model.node_names, margline(1:2)) ;
%             assert(str2num(margline(4)) == model.sizes(indVar)) ;
%             ME_marg{indVar} = sscanf(fgetl(fin),'%g') ;
%             assert(sum(abs(marg{indVar} - ME_marg{indVar})) < thh1) ;
%         end
%     end
    
    fprintf('********* Iteration %i passed!\n',iteNum) ;   
%     model
%     tradeType
%     ResQ
%     toc
        
%     tradeHist{iteNum}.user = user ; 
%     tradeHist{iteNum}.model = model ;
    clear varName varSize ;    
end

fclose(fin) ;
fclose(fout) ;