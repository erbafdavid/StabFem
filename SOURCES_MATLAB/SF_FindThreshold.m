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

global ff ffMPI ffdir ffdatadir sfdir verbosity

mycp(baseflow.filename, [ffdatadir, 'BaseFlow_guess.txt']);
mycp(eigenmode.filename, [ffdatadir, 'Eigenmode_guess.txt']);


switch(lower(baseflow.mesh.problemtype))
    case('2d')
solvercommand = [ff, ' ', ffdir, 'FindThreshold2D.edp'];
    case('axixr')
solvercommand = [ff, ' ', ffdir, 'FindThresholdAxi.edp']; 
    case('2dcomp')
solvercommand = ['echo ', num2str(baseflow.Ma) ' ', num2str(baseflow.Re), ' | ', ffMPI, ' ', ffdir, 'FindThreshold2DComp.edp'];
    otherwise
        error('Error in SF_FindThreshold : not (yet) available for this class of problems')
end

status = mysystem(solvercommand);

mydisp(1,['#### Direct computation of instability threshold ']);

baseflowT = importFFdata(baseflow.mesh, 'BaseFlow_threshold.ff2m');
eigenmodeT = importFFdata(baseflow.mesh, 'Eigenmode_threshold.ff2m');

mydisp(1,['#### Re_c =  ', num2str(baseflowT.Re)]);
mydisp(1,['#### omega_c =  ', num2str(imag(eigenmodeT.lambda))]);


% The following is probably useless... moreover system(cp...) shoud be replaced by mycp
if (nargout > 0)
    baseflow = baseflowT;
    system(['cp ', ffdatadir, 'BaseFlow_threshold.txt ', ffdatadir, 'BaseFlow.txt']);
    system(['cp ', ffdatadir, 'BaseFlow_threshold.txt ', ffdatadir, 'BaseFlow_guess.txt']);
end
if (nargout > 1)
    eigenmode = eigenmodeT;
    system(['cp ', ffdatadir, 'Eigenmode_threshold.txt ', ffdatadir, 'Eigenmode_guess.txt']);
end

end
