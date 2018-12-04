
function [meanflow, mode] = SF_HB1(meanflow, mode, varargin)
%> StabFem wrapper for Harmonic Balance order 1 (idem as Self-Consistent model of Mantic lugo et al.)
%>
%> usage : [meanflow,mode] = SF_HB1(meanflow,mode,[Param1, Value1,...])
%>
%> first argument is either a "baseflow" or a "meanflow"
%> second argument is either an "eigenmode" or a "harmonicmode".
%>
%> Parameters include :
%>
%>   Re :        Reynolds number (specify only if it differs from the one of base flow, which is not usual)
%>   Aguess :    Amplitude for renormalising the eigenmode/SCmode
%>   Fyguess :   Lift for renormalising the eigenmode/SCmode
%>   (if none of these is present then no renormalization is done)
%>   omegaguess : guess for frequency (if not provided we take the im. part of the eigenvalue of the mode)
%>   sigma  :    instantaneous growth rate (nonzero for SC model ; zero for HB model)
%>   specialmode :  if value is 'NEW', recomputation will be forced even if result files seems to be already present
%>
%>  Copyright D. Fabre, 2018

global ff ffdir ffdatadir sfdir verbosity

%%% management of optionnal parameters : definition and default values
p = inputParser;
addParameter(p, 'Re', meanflow.Re, @isnumeric);
addParameter(p, 'Aguess', -1, @isnumeric);
addParameter(p, 'Fyguess', -1, @isnumeric);
addParameter(p, 'Amp', -1, @isnumeric);
addParameter(p, 'omegaguess', imag(mode.lambda));
addParameter(p, 'sigma', 0);
addParameter(p, 'specialmode', 'normal');
parse(p, varargin{:});

%%% definition of the solvercommand string and file names

switch (meanflow.mesh.problemtype)
    
    case('2D')
        
        if(p.Results.Amp ~= -1)
            AMP = p.Results.Amp;
        elseif (p.Results.Fyguess ~= -1)
            mydisp(2,['starting with guess Lift force : ', num2str(p.Results.Fyguess)]);
            AMP = p.Results.Fyguess/mode.Fy;
        elseif (p.Results.Aguess ~= -1)
            mydisp(2,['starting with guess amplitude (Energy) ', num2str(p.Results.Aguess)]);
            AMP = p.Results.Aguess/mode.Aenergy;
        else
            AMP = 1;
        end
        
         solvercommand = ['echo ', num2str(p.Results.Re), ' ', num2str(p.Results.omegaguess), ' ', num2str(p.Results.sigma), ...
                '  ',num2str(real(AMP)) ' ' num2str(imag(AMP)) ' | '  ff, ' ', ffdir, 'HB1_2D.edp'];
        
        Re = p.Results.Re;
        filenameBase = [ffdatadir 'MEANFLOWS/MeanFlow_Re' num2str(Re)];
        filenameHB1 = [ffdatadir 'MEANFLOWS/HBMode1_Re' num2str(Re)];
        filenameHB2 = [ffdatadir 'MEANFLOWS/HBMode2_Re' num2str(Re)];% this one should not be present
        
         case('2DComp')
       % (...) %
        
         solvercommand = ['echo ', num2str(p.Results.Re), ' ', num2str(p.Results.omegaguess), ' ', num2str(p.Results.sigma), ...
                '  ',num2str(real(AMP)) ' ' num2str(imag(AMP)) ' | '  ff, ' ', ffdir, 'HB1_2DComp.edp'];
        
            % to be checked with Javier.... 

        % case("your case...")
        % add your case here !
                
    otherwise
        error(['Error in SF_HB1 : your case ', meanflow.mesh.problemtype 'is not yet implemented....'])
        
end

if(exist([filenameBase '.txt'])==2)&&(exist([filenameHB1 '.txt'])==2)...
    &&(exist([filenameHB2 '.txt'])==0)&&(strcmpi(p.Results.specialmode,'NEW')==0)&&(p.Results.sigma==0)
    
    %%% Recover results from a previous calculation
    mydisp(1,['#### Self-Consistent (HB1) CALCULATION seems to be previously done... recover files ...' ]);
    meanflow = importFFdata(meanflow.mesh,[filenameBase '.ff2m']);
    mode = importFFdata(meanflow.mesh,[filenameHB1 '.ff2m']);
    
else
    
    %%% position input files for the freefem solver...
    mycp(meanflow.filename, [ffdatadir, 'MeanFlow_guess.txt']);
    mycp(mode.filename, [ffdatadir, 'HBMode1_guess.txt']);
    
    %%% Lanch the FreeFem solver
    mydisp(1,['#### LAUNCHING Self-Consistent (HB1) CALCULATION for Re = ', num2str(p.Results.Re) ' ...' ]);
    status = mysystem(solvercommand);
    
    
    if (status==1)
        
        error('ERROR in SF_HarmonicBalance : Freefem program failed to run  !')
        
    elseif (status==2)
        meanflow.iter = -1; mode.iter = -1;
        if(verbosity>1)
            error('ERROR in SF_HarmonicBalance : Newton iteration did not converge !')
        else
            disp('ERROR in SF_HarmonicBalance : Newton iteration did not converge !')
        end
        
    elseif(status==0)
        
        mydisp(1,['#### Self-Consistent (HB1) CALCULATION COMPLETED with Re = ', num2str(p.Results.Re), ' ; sigma = ', num2str(p.Results.sigma)]);
        mydisp(1,['#### omega =  ', num2str(imag(mode.lambda))]);
        
        %%% Copies the output files into "stable" names and imports them
        mycp([ffdatadir, 'MeanFlow.txt'],[filenameBase '.txt']);
        mycp([ffdatadir, 'MeanFlow.ff2m'],[filenameBase '.ff2m']);
        meanflow = importFFdata(meanflow.mesh,[filenameBase '.ff2m']);
        
        mycp([ffdatadir, 'HBMode1.txt'],[filenameHB1 '.txt']);
        mycp([ffdatadir, 'HBMode1.ff2m'],[filenameHB1 '.ff2m']);
        mode = importFFdata(meanflow.mesh,[filenameHB1 '.ff2m']);
        
        myrm(filenameHB2); % to avoid possible bad interaction with HB2 
        
    else
        error(['ERROR in SF_HB1 : return code of the FF solver is ',value]);
    end
    
end


