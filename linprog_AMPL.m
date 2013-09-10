% Function to solve a linear program using an online AMPL solver. The
% submission is via Python, so Python must be installed (and set as the
% default execution program for Python script, under Windows).
% 
% The problem is first written into files in APML code, and then sent to
% the server via a Python script (originally found at: http://www.neos-server.org/neos/NeosClient.py). 
% The NEOS APIs can also be found at http://www.neos-guide.org/content/NEOS-API
% 
% 
% While most of the inputs are the same as Matlab's linprog (and in the
% same order), the options structure (if included) must have the following
% fields:
% s_Solver: String specifying the solver ('MoSEK'/'OOQP')
% s_FormatNum: String specifying how numbers are formatted (default =
% '%.2f').

function [dV_X d_FVAL EXITFLAG s_Result] = linprog_AMPL(dV_Cost, dM_Aineq, dV_bineq, dM_Aeq, dV_beq, dV_LB, dV_UB, dV_x0, Options)

if(size(dV_Cost,2)~=1)
    error('Cost must be a column vector');
end

if(nargin<9)
    Options.s_FormatNum = '%.2f';
    Options.s_Solver = 'OOQP';
    if(nargin<7)
        dV_UB = 0*dV_Cost+NaN;
        if(nargin<6)
            dV_LB = 0*dV_Cost+NaN;
            if(nargin<5)
                dV_beq = [];
                if(nargin==4), error('Cannot find equality matrix'); end
                dM_Aeq = [];
                if(nargin<3)
                    dV_bineq = [];
                    if(nargin==2), error('Cannot find inequality matrix'); end
                    if(nargin<=2), error('Linear problem not properly defined');
                    end, end, end, end, end, end
try
    if(~ischar(Options.s_FormatNum))
        error('Invalid precision format');
    end
catch
    Options.s_FormatNum = '%.4f';
end

% Different solvers report solutions differently
if(strcmp(Options.s_Solver,'OOQP'))
    s_CheckObjective = 'Objective value:     ';
elseif(strcmp(Options.s_Solver,'MoSEK'))
    s_CheckObjective = 'Primal objective  : ';
else
    error('Unknown solver!');
end
% Get path to the data/script files
s_PathToFile = which('MoSEK3.txt');
s_PathToPythonScript = which('NeosClient.py');
s_PathToFile = s_PathToFile(1:strfind(s_PathToFile,'MoSEK3.txt')-1);
s_PathToPythonScript = s_PathToPythonScript(1:strfind(s_PathToPythonScript,'NeosClient.py')-1);
if(isempty(s_PathToFile) || isempty(s_PathToPythonScript))
    error('Cannot find support files');
end

s_IdentStr=strrep(strrep(strrep(datestr(now,0),':','_'),'/','_'),' ','_');
[s_ModelFile s_DataFile s_CmtFile] = LP2AMPL(s_IdentStr,dV_Cost,dM_Aineq,dV_bineq,dM_Aeq,dV_beq,dV_LB,dV_UB,Options);
if(isunix)
    system(['cat ' s_PathToFile Options.s_Solver '1.txt ' s_ModelFile ' ' s_PathToFile Options.s_Solver '2.txt ' s_DataFile ' ' s_PathToFile Options.s_Solver '3.txt ' s_CmtFile ' ' s_PathToFile Options.s_Solver '4.txt > ' s_IdentStr '_MoSEK_XML.xml']);
    s_ExecuteOnNEOS = [s_PathToPythonScript 'NeosClient.py ' s_IdentStr '_MoSEK_XML.xml'];
    [status, s_Result]=system(s_ExecuteOnNEOS);
    system(['rm ' s_ModelFile ' ' s_DataFile ' ' s_CmtFile ' ' s_IdentStr '_MoSEK_XML.xml']);
else
    system(['copy /Y "' s_PathToFile Options.s_Solver '1.txt"+' strrep(s_ModelFile,'/','\') '+"' s_PathToFile Options.s_Solver '2.txt"+' strrep(s_DataFile,'/','\') '+"' s_PathToFile Options.s_Solver '3.txt"+' strrep(s_CmtFile,'/','\') '+"' s_PathToFile Options.s_Solver '4.txt" ' s_IdentStr '_MoSEK_XML.xml']);
    s_ExecuteOnNEOS = ['"' s_PathToPythonScript 'NeosClient.py" ' s_IdentStr '_MoSEK_XML.xml'];
    [status, s_Result]=system(s_ExecuteOnNEOS);
    system(['del /Q ' s_ModelFile ' ' s_DataFile ' ' s_CmtFile ' ' s_IdentStr '_MoSEK_XML.xml']);
end

hFile_ResultFile = fopen('Result.txt','w');
fprintf(hFile_ResultFile,'%s',s_Result);
fclose(hFile_ResultFile);
pause(0.1);

dV_X = [];
if(isempty(strfind(s_Result,'Error')) && isempty(strfind(s_Result,'INFEASIBLE')))
    EXITFLAG = 1;
    hFile_ResultFile = fopen('Result.txt','r');
    if(~hFile_ResultFile)
        display('Cannot find Result.txt');
        dV_X = NaN;
        d_FVAL = NaN;
        EXITFLAG = 0;
        return
    end
    s_GetResLine = fgetl(hFile_ResultFile);
    while(isempty(strfind(s_GetResLine,'[*] :='))) % Keep reading till the solution.
        if(~ischar(s_GetResLine))
            break;
        end
        if(~isempty(strfind(s_GetResLine,s_CheckObjective))) % We found the cost
            n_StartStr = strfind(s_GetResLine,s_CheckObjective)+length(s_CheckObjective);
            if(strcmp(Options.s_Solver,'OOQP'))
                s_FVal = s_GetResLine(n_StartStr:end-1);
                d_FVAL = str2double(s_FVal);
            elseif(strcmp(Options.s_Solver,'MoSEK'))
                s_FVal = s_GetResLine(n_StartStr:end);
                d_FVAL = str2double(s_FVal);
            else
                error('Unknown solver!');
            end            
        end
        s_GetResLine = fgetl(hFile_ResultFile);
    end
    s_ResultStr = fgetl(hFile_ResultFile);
    while(isempty(strfind(s_ResultStr,';')));
        if(~ischar(s_ResultStr))
            break;
        end
        dV_ResultRow = str2num(s_ResultStr);
        nV_ResultRowIndx = round(dV_ResultRow(1:2:end));
        dV_X(nV_ResultRowIndx,1) = dV_ResultRow(2:2:end);
        s_ResultStr = fgetl(hFile_ResultFile);
        pause(0.1);
    end
    fclose(hFile_ResultFile);
    
    % delete the result file.
    if(isunix)
        system('rm Result.txt');
    else
        system('del /Q Result.txt');
    end
else
    EXITFLAG = 0;
    dV_X = NaN;
    d_FVAL = NaN;
end

if(isempty(dV_X))
    dV_X = NaN;
    d_FVAL = NaN;
    EXITFLAG = 0;
end

if(~exist('d_FVAL','var'))
    d_FVAL = dV_Cost'*dV_X;
    EXITFLAG = 2;
end
end