% This function converts regular Matlab linear programming to AMPL format
% and stores it in files.

function [s_MdlFile s_DataFile s_CmtFile]=LP2AMPL(s_FileName,dV_Cost,dM_Aineq,dV_bineq,dM_Aeq,dV_beq,dV_LB,dV_UB,k_Options)

%% First write the data file
s_DataFile = [s_FileName '_Data.dat'];

hFile_DataFile = fopen([s_FileName '_Data.dat'],'w');

% try
%     s_FormatNum = repmat([k_Options.s_FormatNum ' '],1,size(dM_Aineq,2));
% catch
%     s_FormatNum = repmat('%f ',1,size(dM_Aineq,2));
% end

% Write the inequality matrix
if(~isempty(dM_Aineq))
    %display('Writing Inequality matrix');
    s_Str1 = num2str(1:size(dM_Aineq,2));
    fprintf(hFile_DataFile,'%s\r\n',['param dM_Aineq: ' s_Str1 ':=']);
    %     hWB_WaitBar = waitbar(0);
    %     for jj = 1:size(dM_Aineq,1)
    %         waitbar(jj/size(dM_Aineq,1),hWB_WaitBar);
    %         fprintf(hFile_DataFile,'\r\n %s',[num2str(jj) ' ' num2str(dM_Aineq(jj,:),s_FormatNum)]);
    %     end
    nV_LineNr = (1:size(dM_Aineq,1))';
    s_dMAineq = sprintf(['%d ' repmat([k_Options.s_FormatNum ' \t'],1,size(dM_Aineq,2)) '\r\n'],[nV_LineNr dM_Aineq]');
    fprintf(hFile_DataFile,s_dMAineq);
    fprintf(hFile_DataFile,';\r\n');
    
    % Write the inequality vector
    %display('Writing Inequality vector');
    fprintf(hFile_DataFile,'%s\r\n','param dV_bineq:=');
    %     hWB_WaitBar = waitbar(0);
    %     s_FormatNum = repmat('%.2f ',1,size(dV_bineq,2));
    %     for jj = 1:size(dV_bineq,1)
    %         waitbar(jj/size(dV_bineq,1),hWB_WaitBar);
    %         fprintf(hFile_DataFile,'\r\n %s',[num2str(jj) ' ' num2str(dV_bineq(jj,:),s_FormatNum)]);
    %     end
    s_dVbineq = sprintf([repmat(['%d ' k_Options.s_FormatNum ' \t'],1,size(dV_bineq,2)) '\r\n'],[nV_LineNr dV_bineq]');
    fprintf(hFile_DataFile,s_dVbineq);
    fprintf(hFile_DataFile,';\r\n');
end

if(~isempty(dM_Aeq))
    % Write the equality matrix
    %display('Writing Equality matrix');
    s_Str1 = num2str(1:size(dM_Aeq,2));
    fprintf(hFile_DataFile,'%s\r\n',['param dM_Aeq: ' s_Str1 ':=']);
    %     hWB_WaitBar = waitbar(0);
    %     s_FormatNum = repmat('%.2f ',1,size(dM_Aeq,2));
    %     for jj = 1:size(dM_Aeq,1)
    %         waitbar(jj/size(dM_Aeq,1),hWB_WaitBar);
    %         fprintf(hFile_DataFile,'\r\n %s',[num2str(jj) ' ' num2str(dM_Aeq(jj,:),s_FormatNum)]);
    %     end
    nV_LineNr = (1:size(dM_Aeq,1))';
    s_dMAeq = sprintf([repmat(['%d ' k_Options.s_FormatNum ' \t'],1,size(dM_Aeq,2)) '\r\n'],[nV_LineNr dM_Aeq]');
    fprintf(hFile_DataFile,s_dMAeq);
    fprintf(hFile_DataFile,';\r\n');
    
    % Write the equality vector
    %display('Writing equality vector');
    fprintf(hFile_DataFile,'%s\r\n','param dV_beq:=');
    %     hWB_WaitBar = waitbar(0);
    %     s_FormatNum = repmat('%.2f ',1,size(dV_beq,2));
    %     for jj = 1:size(dV_beq,1)
    %         waitbar(jj/size(dV_beq,1),hWB_WaitBar);
    %         fprintf(hFile_DataFile,'\r\n %s',[num2str(jj) ' ' num2str(dV_beq(jj,:), s_FormatNum)]);
    %     end
    s_dVbeq = sprintf([repmat(['%d ' k_Options.s_FormatNum ' \t'],1,size(dV_beq,2)) '\r\n'],[nV_LineNr dV_beq]);
    fprintf(hFile_DataFile,s_dVbeq);
    fprintf(hFile_DataFile,';\r\n');
end

% Write the lower bound
nV_LB = find(~isnan(dV_LB));
if(~isempty(nV_LB))
    nV_LineNr = (1:length(nV_LB))';
    fprintf(hFile_DataFile,'\r\n %s;',['param n_NrLB:= ' num2str(length(nV_LB))]);
    fprintf(hFile_DataFile,'\r\n %s\r\n','param dM_LB: 1 2 :=');
    s_LB = sprintf([repmat(['%d ' k_Options.s_FormatNum ' %d'],1,1) '\r\n'],[nV_LineNr dV_LB(nV_LB) nV_LB]');
    fprintf(hFile_DataFile,s_LB);
    fprintf(hFile_DataFile,';\r\n');
end

% Write the upper bound
nV_UB = find(~isnan(dV_UB));
if(~isempty(nV_UB))
    nV_LineNr = (1:length(nV_UB))';
    fprintf(hFile_DataFile,'\r\n %s;',['param n_NrUB:= ' num2str(length(nV_UB))]);
    fprintf(hFile_DataFile,'\r\n %s\r\n','param dM_UB: 1 2 :=');
    s_UB = sprintf([repmat(['%d ' k_Options.s_FormatNum ' %d'],1,1) '\r\n'],[nV_LineNr dV_UB(nV_UB) nV_UB]');
    fprintf(hFile_DataFile,s_UB);
    fprintf(hFile_DataFile,';\r\n');    
end

% Write the cost vector
%display('Writing cost vector');
fprintf(hFile_DataFile,'%s\r\n','param dV_Cost:=');
% hWB_WaitBar = waitbar(0);
% s_FormatNum = repmat('%.2f ',1,size(dV_Cost,2));
% for jj = 1:size(dV_Cost,1)
%     waitbar(jj/size(dV_Cost,1),hWB_WaitBar);
%     fprintf(hFile_DataFile,'\r\n %s',[num2str(jj) ' ' num2str(dV_Cost(jj,:), s_FormatNum)]);
% end
nV_LineNr = (1:size(dV_Cost,1))';
s_dVCost = sprintf([repmat([k_Options.s_FormatNum ' \t'],1,size(dV_Cost,2)) '\r\n'],[nV_LineNr dV_Cost]');
fprintf(hFile_DataFile,s_dVCost);
fprintf(hFile_DataFile,';\r\n');

%display('Writing other data');
n_NrVariables = size(dM_Aineq,2);
if(n_NrVariables==0)
    n_NrVariables = size(dM_Aeq,2);
end
    
fprintf(hFile_DataFile,'\r\n %s;',['param n_NrVars:=' num2str(n_NrVariables)]);
if(~isempty(dM_Aineq))
    fprintf(hFile_DataFile,'\r\n %s;',['param n_NrIneq:=' num2str(size(dM_Aineq,1))]);
end
if(~isempty(dM_Aeq))
    fprintf(hFile_DataFile,'\r\n %s;',['param n_NrEq:=' num2str(size(dM_Aeq,1))]);
end
fclose(hFile_DataFile);

%% Now write the model file
s_MdlFile=[s_FileName '_Mod.mod'];
%display('Writing Model file');
hFile_ModFile = fopen([s_FileName '_Mod.mod'],'w');

fprintf(hFile_ModFile,'\r\n param n_NrVars;');
if(~isempty(dM_Aineq))
    fprintf(hFile_ModFile,'\r\n param n_NrIneq;');
end
if(~isempty(dM_Aeq))
    fprintf(hFile_ModFile,'\r\n param n_NrEq;');
end

if(~isempty(nV_LB))
    fprintf(hFile_ModFile,'\r\n param n_NrLB;');
    fprintf(hFile_ModFile,'\r\n param dM_LB{j in 1..n_NrLB, i in 1..2};');
end
if(~isempty(nV_UB))
    fprintf(hFile_ModFile,'\r\n param n_NrUB;');
    fprintf(hFile_ModFile,'\r\n param dM_UB{j in 1..n_NrUB, i in 1..2};');
end

fprintf(hFile_ModFile,'\r\n param dV_Cost{i in 1..n_NrVars};');
if(~isempty(dM_Aineq))
    fprintf(hFile_ModFile,'\r\n param dM_Aineq{j in 1..n_NrIneq, i in 1..n_NrVars};');
    fprintf(hFile_ModFile,'\r\n param dV_bineq{j in 1..n_NrIneq};');
end
if(~isempty(dM_Aeq))
    fprintf(hFile_ModFile,'\r\n param dM_Aeq{j in 1..n_NrEq, i in 1..n_NrVars};');
    fprintf(hFile_ModFile,'\r\n param dV_beq{j in 1..n_NrEq};');
end

fprintf(hFile_ModFile,'\r\n var x{i in 1..n_NrVars};');
fprintf(hFile_ModFile,'\r\n minimize cost: sum{i in 1..n_NrVars} x[i]*dV_Cost[i];');
if(~isempty(dM_Aineq))
    fprintf(hFile_ModFile,'\r\n subject to IneqCons{j in 1..n_NrIneq}: sum{i in 1..n_NrVars} dM_Aineq[j,i]*x[i] <= dV_bineq[j];');
end
if(~isempty(dM_Aeq))
    fprintf(hFile_ModFile,'\r\n subject to EqCons{j in 1..n_NrEq}: sum{i in 1..n_NrVars} dM_Aeq[j,i]*x[i] = dV_beq[j];');
end

if(~isempty(nV_LB))
    fprintf(hFile_ModFile,'\r\n subject to LBCons{j in 1..n_NrLB}: dM_LB[j,1] <= x[dM_LB[j,2]];');
end
if(~isempty(nV_UB))
    fprintf(hFile_ModFile,'\r\n subject to UBCons{j in 1..n_NrUB}: x[dM_UB[j,2]] <= dM_UB[j,1];');    
end

fclose(hFile_ModFile);

%% Now the comments file, if it exists
b_IsComments = 0;
try
    k_Options.Comments;
    b_IsComments = 1;
end
s_CmtFile = [s_FileName '_Com.txt'];
%display('Writing Comments file');
hFile_Comments = fopen([s_FileName '_Com.txt'],'w');
if(b_IsComments)
    fprintf(hFile_Comments, '\r\n%s\r\n',s_Comments);
end
fclose(hFile_Comments);


end