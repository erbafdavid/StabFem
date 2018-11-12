function res = SF_LinearForced(bf,omega,varargin);
%>
%> Function SF_LinearForced
%>
%> This function solves a linear, forced problem for a single value of
%> omega or for a range of omega (for instance impedance computations)
%>
%> Usage :
%> 1/ res = SF_LinearForced(bf,omega) (single omega mode)
%>      in this case res will be a flowfield structure 
%> 
%>  2/ res = SF_LinearForced(bf,omega) (loop-omega mode)
%>      in this case res will be a structure composed of arrays, as specified in the Macro_StabFem.edp 
%>      (for instance omega and Z)
%>
%>  Parameters : 'plot','yes' => the program will plot the impedance and
%>                               Nyquist diagram
%>
%> Copyright D. Fabre, 11 oct 2018
%> This program is part of the StabFem project distributed under gnu licence.

global ff ffMPI ffdir ffdatadir sfdir verbosity

   p = inputParser;
   addParameter(p,'plot','no',@ischar);  
   parse(p,varargin{:});


% Position input files
if(strcmpi(bf.datatype,'Mesh')==1)
       % first argument is a simple mesh
       ffmesh = bf; 
       mycp(ffmesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
else
       % first argument is a base flow
       ffmesh = bf.mesh;
       mycp(bf.filename,[ffdatadir 'BaseFlow.txt']);
       mycp(bf.mesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
end

switch ffmesh.problemtype
    case('AxiXRCOMPLEX')
        solver = [ffdir 'LinearForcedAxi_COMPLEX_m0.edp'];
        FFfilename = [ffdatadir 'Field_Impedance_Re' num2str(bf.Re) '_Omega' num2str(omega(1))];
        FFfilenameStat = [ffdatadir 'Impedances_Re' num2str(bf.Re)];
    case('AxiXR') % Jet sifflant Axi Incomp.
        solver = [ffdir  'LinearForcedAxi_m0.edp'];
        FFfilename = [ffdatadir 'Field_Impedance_Re' num2str(bf.Re) '_Omega' num2str(omega(1))];
        FFfilenameStat = [ffdatadir 'Impedances_Re' num2str(bf.Re)];
    case({'2D','2DMobile'}) % VIV
        solver = [ffdir 'LinearForced2D.edp'];
        FFfilename = [ffdatadir 'Field_Impedance_Re' num2str(bf.Re) '_Omega' num2str(omega(1))];
        FFfilenameStat = [ffdatadir 'Impedances_Re' num2str(bf.Re)];
    %case('AcousticAxi') A completer  
    otherwise
        error(['Error : problemtype ' ffmesh.problemtype ' not recognized']);
end


paramstring = [' array ' num2str(length(omega))];
for i=1:length(omega)
    paramstring = [paramstring ' ' num2str(real(omega(i))),' ',num2str(imag(omega(i))) ]
end

 solvercommand = ['echo ',paramstring,' | ', ff, ' ', solver];
 errormsg = 'Error in SF_ForcedFlow';
 mysystem(solvercommand, errormsg);
 
 if(length(omega)==1)
    mycp([ffdatadir 'ForcedFlow.ff2m'],[FFfilename, '.ff2m']);
    mycp([ffdatadir 'ForcedFlow.txt'],[FFfilename, '.txt']);
    res = importFFdata(bf.mesh, [FFfilename, '.ff2m']);
    
 else
    mycp([ffdatadir 'LinearForcedStatistics.ff2m'],[FFfilenameStat,'.ff2m']);
    res = importFFdata(bf.mesh, [FFfilenameStat,'.ff2m']);
    
    %plots...
    if(~strcmp(p.Results.plot,'no'))
    subplot(1,2,1); hold on;
    plot(res.omega,real(res.Z),'b-',res.omega,-imag(res.Z)./res.omega,'b--');hold on;
    plot(res.omega,0*real(res.Z),'k:','LineWidth',1)
    xlabel('\omega');ylabel('Z_r, -Z_i/\omega');
    title(['Impedance for Re = ',num2str(bf.Re)] );
    subplot(1,2,2);hold on;
    plot(real(res.Z),imag(res.Z)); title(['Nyquist diagram for Re = ',num2str(bf.Re)] );
    xlabel('Z_r');ylabel('Z_i');ylim([-10 2]);
    box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos);
    pause(0.1);
    end
    
    
 end

 
end