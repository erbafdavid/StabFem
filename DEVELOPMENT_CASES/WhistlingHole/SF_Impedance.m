function FF = SF_Impedance(bf,omega);

global ff ffMPI ffdir ffdatadir sfdir verbosity

 solvercommand = ['echo ', num2str(omega),' | ', ff, ' ', 'Impedance.edp'];
 error = 'Error in SF_ForcedFlow';
 mycp(bf.filename, [ffdatadir, 'BaseFlow.txt']);
 mycp(bf.mesh.filename, [ffdatadir, 'mesh.msh']);
 mysystem(solvercommand, error);
 FFfilename = [ffdatadir 'ForcedFlow_Re' num2str(bf.Re) '_Omega' num2str(omega)]
 FF = importFFdata(bf.mesh, [FFfilename, '.ff2m']);
 FF.filename = [FFfilename, '.txt']; %maybe redundant ?
 
end
