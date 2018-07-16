%> @file SOURCES_MATLAB/SF_FindThreshold.m
%> @brief TODO ADD DESCRIPTION HERE
%>
%> @param[in] baseflow: TODO ADD DESCRIPTION HERE
%> @param[in] eigenmode: TODO ADD DESCRIPTION HERE
%> @param[out] baseflow: TODO ADD DESCRIPTION HERE
%> @param[out] eigenmode: TODO ADD DESCRIPTION HERE
%>
%> usage: <code>[baseflow, eigenmode] = SF_FindThreshold(baseflow, eigenmode)</code>
%>
%> ADD COMPLETE DOCUMENTATION HERE
%>
%> @author David Fabre
%> @date 2017-2018
%> @copyright GNU Public License
function [baseflow, eigenmode] = SF_FindThreshold(baseflow, eigenmode)

% Direct computation of instability threshold

global ff ffdir ffdatadir sfdir verbosity

system(['cp ' ffdatadir 'Eigenmode.txt ' ffdatadir 'Eigenmode_guess.txt']);

 solvercommand = [ff ' ' ffdir 'FindThreshold2D.edp'];
        status = mysystem(solvercommand);
        
disp(['#### Direct computation of instability threshold ']);

baseflowT=importFFdata(baseflow.mesh,'BaseFlow_threshold.ff2m');
eigenmodeT=importFFdata(baseflow.mesh,'Eigenmode_threshold.ff2m');


disp(['#### Re_c =  ' num2str(baseflowT.Re) ]);
disp(['#### lambda_c =  ' num2str(eigenmodeT.lambda) ]);

if(nargout>0)
baseflow=baseflowT;
system(['cp ',ffdatadir,'BaseFlow_threshold.txt ',ffdatadir,'BaseFlow.txt']);
system(['cp ',ffdatadir,'BaseFlow_threshold.txt ',ffdatadir,'BaseFlow_guess.txt']);
end


if(nargout>1)
eigenmode=eigenmodeT;
system(['cp ',ffdatadir,'Eigenmode_threshold.txt ',ffdatadir,'Eigenmode_guess.txt']);
end



        