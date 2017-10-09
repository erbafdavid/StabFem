function SF_Spectrum_Exploration(baseflow,Re_set,m_set,shift_set);
%
%  Spectrum exporator tool.
%  
%  Two usage modes according to the number of parameters.
% 
%  FreeFem_Spectrum_Exploration(baseflow) 
%   -> interactive mode : parameters will be entered by keyboard
%
%  FreeFem_Spectrum_Exploration(baseflow,Re_set,m_set,shift_set)
%   -> non interactive mode
%  
%  part of Stabfem FreeFem/Matlab interface, version 2.1
%  D Fabre, 


global ff ffdir ffdatadir

% decides which mode to use and set the parameters 
if(nargin==1) 
    disp('SPECTRUM EXPLORATOR : INTERACTIVE MODE');
elseif(nargin==4)
    disp('SPECTRUM EXPLORATOR : NON-INTERACTIVE MODE');
    NRUNS = max([length(Re_set),length(m_set),length(shift_set)]);
    if(length(Re_set)==1)
            Re_RUNS=Re_set*ones(1,NRUNS)
    else
            RE_RUNS=Re_set
    end
     if(length(m_set)==1)
            m_RUNS=m_set*ones(1,NRUNS)
    else
            m_RUNS=m_set
     end
     if(length(shift_set)==1)
            shift_RUNS=shift_set*ones(1,NRUNS)
    else
            shift_RUNS=shift_set
    end
else
    error('ERROR in SPECTRUM EXPLORATOR : wrong number of parameters');
end

    iRUN = 1;
    mycmp = [[0 0 0];[1 0 1] ;[0 1 1]; [1 1 0]; [1 0 0];[0 1 0];[0 0 1]]; %color codes for symbols
       
while(iRUN>0) 
    disp(['Spectrum computation # ' num2str(iRUN) '\n']); 
    if(nargin==1) % interactive mode
        Re = myinput('Enter Reynolds number : ',250);  
        m = myinput('Enter wavenumber m : ',1);  
        shift = myinput('Enter shift (complex)  : ',0.2+0.4i);
        nev = myinput('Enter nev (negative for adjoint problem ; 0 to stop calculations) : ',10);
    else % non-interactive mode
        Re = Re_RUNS(iRUN)
        m = m_RUNS(iRUN)
        shift = shift_RUNS(iRUN)
    end
    
if(exist(['' ffdatadir '/BaseFlow_Re' num2str(Re) '.txt'])==2);
    disp('base flow already computed');
    system(['cp ' ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt BaseFlow.txt']);
else
    disp('computing base flow ');
    baseflow=SF_BaseFlow(baseflow,Re);
end

disp('performing stability computation');

    EV = SF_Stability(baseflow,'m',m,'shift',shift,'nev',10)

system(['mkdir ' ffdatadir '/RUN' num2str(iRUN)]);
system(['mv Eigenmode*.ff2m ' ffdatadir '/RUN' num2str(iRUN) '/']);
system(['cp Eigenvalues.txt ' ffdatadir '/RUN' num2str(iRUN) '/']);

EVr = real(EV);
EVi = imag(EV);

if(iRUN==1)
    handle = figure();
else
    figure(handle);
end
for ind=1:length(EVr);
  %%%% plot spectrum
  h=plot(imag(shift),real(shift),'o','MarkerEdgeColor',mycmp(mod(iRUN,7)+1,:));hold on;
  h=plot(EVi(ind),EVr(ind),'*','MarkerEdgeColor',mycmp(mod(iRUN,7)+1,:));hold on;
  xlabel('\sigma_i');ylabel('\sigma_r');
  title('Computed eigenvalues (click to see eigenmodes)')
  %%%%  plotting command for eigenmodes and callback function 
  tt=['eigenmodeP= importFFdata(baseflow.mesh, ''' ffdatadir 'RUN' num2str(iRUN) '/Eigenmode' num2str(ind) '.ff2m''); ' ... 
      'eigenmodeP.xlim = [-1 , 3]; eigenmodeP.plottitle =''Eigenmode for Re = ',num2str(Re),' , m = ',num2str(m), ...
      ', sigma = ', num2str(EVr(ind)) ' + 1i * ' num2str(EVi(ind)) ' '' ; '... 
      'plotFF(eigenmodeP,''ux1'',1); '  ];
  set(h,'buttondownfcn',tt);
end
   pause(0.1); % to allow refreshing of figures
   
    if(nargin==1) % end of loop for interactive mode
    rep = myinput('\n What to do next ? [0=stop] [1=continue, add new data to existing] [2=continue, clean previous data]',1);  
    if(rep==1)
        iRUN=iRUN+1;
    elseif(rep==2)
        iRUN = 1;
        close(handle); 
        handle=figure();
    else
        iRUN = -1;
    end
    else  % end of loop for noninteractive mode
        if(iRUN<NRUNS)
            iRUN=iRUN+1;
        else
            iRUN = -1;
        end
    end
end

