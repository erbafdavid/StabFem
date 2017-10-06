
function [meanflow,mode] = SF_HarmonicBalance(meanflow,mode,varargin)

%%% management of optionnal parameters
    p = inputParser;
   addParameter(p,'Re',meanflow.Re,@isnumeric);
   addParameter(p,'Aguess',-1,@isnumeric);
   addParameter(p,'omegaguess',imag(mode.lambda));
   addParameter(p,'sigma',0);
   addParameter(p,'Lguess',-1,@isnumeric);
   parse(p,varargin{:});


global ff ffdir ffdatadir sfdir verbosity

if(meanflow.datatype=='BaseFlow')
    disp('### Harmonic Balance  : with guess from BaseFlow/Eigenmode');
    system(['cp ',ffdatadir, 'BaseFlow.txt ',ffdatadir, 'MeanFlow_guess.txt']);
    system(['cp ',ffdatadir, 'Eigenmode.txt ',ffdatadir, 'SelfConsistentMode_guess.txt']);
    
elseif(meanflow.datatype=='MeanFlow')
    disp('### SelfConsistent : with guess from MeanFlow/SCMode');
    system(['cp ',ffdatadir, 'MeanFlow.txt ',ffdatadir, 'MeanFlow_guess.txt']);
    system(['cp ',ffdatadir, 'SelfConsistentMode.txt ',ffdatadir, 'SelfConsistentMode_guess.txt']);  

else
    error('ERROR to be fixed on next monday (hihihi... DAvid)'); 
end

 if(p.Results.Lguess~=-1) 
      disp(['starting with guess Lift ' num2str(p.Results.Lguess) ]);
     solvercommand = ['echo ' num2str(p.Results.Re)  ' ' num2str(p.Results.omegaguess) ' ' num2str(p.Results.sigma)...
                  ' L ' num2str(p.Results.Lguess) ' | ' ff ' '  ffdir 'HarmonicBalance_2D.edp'];
 elseif(p.Results.Aguess~=-1)
      disp(['starting with guess amplitude (Energy) ' num2str(p.Results.Aguess) ]);
     solvercommand = ['echo ' num2str(p.Results.Re)  ' ' num2str(p.Results.omegaguess) ' ' num2str(p.Results.sigma)...
                  ' E ' num2str(p.Results.Aguess) ' | ' ff ' '  ffdir 'HarmonicBalance_2D.edp'];
 else
     solvercommand = ['echo ' num2str(p.Results.Re)  ' ' num2str(p.Results.omegaguess) ' ' num2str(p.Results.sigma)...
                  ' None  | ' ff ' '  ffdir 'HarmonicBalance_2D.edp'];    
 end
   
   
 status = mysystem(solvercommand);

               
disp(['#### SELF CONSISTENT CALCULATION COMPLETED with Re = ' num2str(p.Results.Re) ' ; sigma = ' num2str(p.Results.sigma)  ]);
meanflow=importFFdata(meanflow.mesh,'MeanFlow.ff2m');
mode=importFFdata(meanflow.mesh,'SelfConsistentMode.ff2m');


disp(['#### omega =  ' num2str(imag(mode.lambda)) ]);
%disp(['#### A =  ' num2str(mode.A) ]);


end

%if(nargout>0)
%system('cp MeanFlow.txt MeanFlow_guess.txt');
%system('cp chbase_threshold.txt Self_guess.txt');
%end


%if(nargout>1)
%eigenmode=eigenmodeT;
%system('cp Eigenmode_threshold.txt Eigenmode_guess.txt');
%end
