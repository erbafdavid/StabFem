function AC = SF_Impedance(baseflow,varargin)
global ff ffdir ffdatadir sfdir verbosity
%%% management of optionnal parameters
    p = inputParser;
    addParameter(p,'k',0.1);
    addParameter(p,'plotPhi','no');
    addParameter(p,'plotaxis','no');
    parse(p,varargin{:});
    
    solvercommand = ['echo ' num2str(p.Results.k) ' | ' ff  ' Impedance_plot.edp'];
        status = mysystem(solvercommand);
              
        
    AC=importFFdata(baseflow.mesh,'AcousticField.ff2m');
    
   if ( strcmp(p.Results.plotPhi,'yes')  ==1)
           plotFF(AC,'Phi');
   end
   
    if ( strcmp(p.Results.plotaxis,'yes')  ==1)
           plot(AC.Xaxis,real(AC.Paxis),'r-',AC.Xaxis,imag(AC.Paxis),'r--',...
               AC.Xaxis,real(AC.Uaxis),'b-',AC.Xaxis,imag(AC.Uaxis),'b--');
           title('Pressure and velocity along the axis ')
           legend('Re(P)', 'Im(P)','Re(U)','Im(U)'); 
   end
   
   
   