
function [meanflow, mode, mode2] = SF_HB2(varargin)
%> StabFem wrapper for Harmonic Balance order 2
%>
%> usage : 
%> 1. [meanflow,mode,mode2] = SF_HB1(meanflow,mode,mode2,'Re',Re)
%>
%> 2. [meanflow,mode,mode2] = SF_HB1(meanflow,mode,'Re',Re)
%>                    (variant to start from HB1 results)
%>
%> first argument is either a "baseflow" or 'meanflow"
%> second argument is either an "eigenmode" or a "selfconsistentmode".
%> third argument is a 'SecondHarmonicMode'.
%>
%> Parameters include :
%>
%>   Re :        Reynolds number (specify only if it differs from the one of base flow, which is not usual)
%>
%>  Copyright D. Fabre, 2018


global ff ffdir ffdatadir sfdir verbosity


%%% management of optionnal parameters
meanflow = varargin{1};
mode = varargin{2};
if(isstruct(varargin{3}))
    mode2 = varargin{3};
    vararginopt = {varargin{4:end}};
else
    mode2 = -1;
    vararginopt = {varargin{3:end}};
end
p = inputParser;
addParameter(p, 'Re', meanflow.Re, @isnumeric);
addParameter(p, 'specialmode', 'normal');
parse(p, vararginopt{:});




%%% definition of the solvercommand string and file names

switch (meanflow.mesh.problemtype)
    
    case('2D')
        solvercommand = ['echo ', num2str(p.Results.Re), ' | ', ff, ' ', ffdir, 'HarmonicBalance_Order2_2D.edp'];        
        Re = p.Results.Re;
        filenameBase = [ffdatadir 'MEANFLOWS/MeanFlow_Re' num2str(Re)];
        filenameHB1 = [ffdatadir 'MEANFLOWS/Harmonic1_Re' num2str(Re)];
        filenameHB2 = [ffdatadir 'MEANFLOWS/Harmonic2_Re' num2str(Re)];
        
        % case("your case...")
        % add your case here !
        
    case default
        error(['Error in SF_HB2 : your case ', meanflow.mesh.problemtype 'is not yet implemented....'])
        
end

if(exist([filenameBase '.txt'])==2)&&(exist([filenameHB1 '.txt'])==2)&&(exist([filenameHB2 '.txt'])==2)&&(strcmp(p.Results.specialmode,'NEW')==0)
    
    %%% Recover results from a previous calculation
    mydisp(1,['#### HB2 CALCULATION for Re = ' num2str(Re) ' seems to be previously done... recover files ...' ]);
    meanflow = importFFdata(meanflow.mesh,[filenameBase '.ff2m']);
    mode = importFFdata(meanflow.mesh,[filenameHB1 '.ff2m']);
    mode2 = importFFdata(meanflow.mesh,[filenameHB2 '.ff2m']);
    
else
    
    %%% position input files for the freefem solver...
    mycp(meanflow.filename, [ffdatadir, 'MeanFlow_guess.txt']);
    mycp(mode.filename, [ffdatadir, 'SelfConsistentMode_guess.txt']);
    if(isstruct(mode2))
        mycp(mode2.filename, [ffdatadir, 'SecondHarmonicMode_guess.txt']);
    else
        myrm([ffdatadir, 'SecondHarmonicMode_guess.txt']);
    end
    %%% Lanch the FreeFem solver
    mydisp(1,['#### LAUNCHING Harmonic-Balance (HB2) CALCULATION for Re = ', num2str(p.Results.Re) ' ...' ]);
    status = mysystem(solvercommand);
   
    
     if (status==1)
         error('ERROR in SF_HB2 : Freefem program failed to run  !')
     elseif (status==2)
        meanflow.iter = -1; mode.iter = -1;mode2.iter = -1;
        if(verbosity>1)
            error('ERROR in SF_HB2 : Newton iteration did not converge !')
        else
            disp('ERROR in SF_HB2 : Newton iteration did not converge !')
        end
        
     elseif(status==0)
        
        mydisp(1,['#### HB2 CALCULATION COMPLETED with Re = ', num2str(p.Results.Re)]);
        mydisp(1,['#### omega =  ', num2str(imag(mode.lambda))]);
        
        %%% Copies the output files into "stable" names and imports them
        mycp([ffdatadir, 'MeanFlow.txt'],[filenameBase '.txt']);
        mycp([ffdatadir, 'MeanFlow.ff2m'],[filenameBase '.ff2m']);
        [filenameBase '.ff2m']
        meanflow = importFFdata(meanflow.mesh,[filenameBase '.ff2m']);
        
        mycp([ffdatadir, 'SelfConsistentMode.txt'],[filenameHB1 '.txt']);
        mycp([ffdatadir, 'SelfConsistentMode.ff2m'],[filenameHB1 '.ff2m']);
        mode = importFFdata(meanflow.mesh,[filenameHB1 '.ff2m']);
        
        mycp([ffdatadir, 'SecondHarmonicMode.txt'],[filenameHB2 '.txt']);
        mycp([ffdatadir, 'SecondHarmonicMode.ff2m'],[filenameHB2 '.ff2m']);
        mode2 = importFFdata(meanflow.mesh,[filenameHB2 '.ff2m']);
        
     else
         error(['ERROR in SF_HB2 : return code of the FF solver is ',value]);
     end
    
end
