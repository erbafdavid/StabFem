function IMP = SF_Acoustic_Impedance(baseflow,varargin)
global ff ffdir ffdatadir sfdir verbosity
%%% management of optionnal parameters
    p = inputParser;
    addParameter(p,'k',0.1);
    addParameter(p,'plotZ','yes');
     addParameter(p,'plotR','no');
    parse(p,varargin{:});
   kmin = p.Results.k(1)
   kmax = p.Results.k(end)
   dk = p.Results.k(2)-p.Results.k(1)
   
    
    solvercommand = ['echo ' num2str(kmin) ' ' num2str(dk) ' ' num2str(kmax)  ' | ' ff  ' FF_Acoustic_Impedance.edp'];
        status = mysystem(solvercommand);
              
        
    IMP=importFFdata(baseflow.mesh,'AcousticImpedances.ff2m');
    
    
  
    
     