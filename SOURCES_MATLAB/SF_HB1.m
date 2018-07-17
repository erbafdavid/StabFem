
function [meanflow, mode] = SF_HB1(meanflow, mode, varargin)
% StabFem wrapper for Harmonic Balance order 1 (idem as Self-Consistent model of Mantic lugo et al.)
%
% usage : [meanflow,mode] = SF_HB1(meanflow,mode,[Param1, Value1,...])
%
% first argument is either a "baseflow" or 'meanflow"
% second argument is either an "eigenmode" or a "selfconsistentmode".
%
% Parameters include :
%
%   Re :        Reynolds number (specify only if it differs from the one of base flow, which is not usual)
%   Aguess :    Amplitude for renormalising the eigenmode/SCmode
%   Fyguess :   Lift for renormalising the eigenmode/SCmode
%   (if none of these is present then no renormalization is done)
%   omegaguess : guess for frequency (if not provided we take the im. part of the eigenvalue of the mode)
%   sigma  :    instantaneous growth rate (nonzero for SC model ; zero for HB model)
%
%  Copyright D. Fabre, 2018

%%% management of optionnal parameters
p = inputParser;
addParameter(p, 'Re', meanflow.Re, @isnumeric);
addParameter(p, 'Aguess', -1, @isnumeric);
addParameter(p, 'Fyguess', -1, @isnumeric);
addParameter(p, 'omegaguess', imag(mode.lambda));
addParameter(p, 'sigma', 0);
%   addParameter(p,'Cyguess',-1,@isnumeric);
parse(p, varargin{:});


global ff ffdir ffdatadir sfdir verbosity

%if(meanflow.datatype=='BaseFlow')
%    mydisp(1,'### Self Consistent  : with guess from BaseFlow/Eigenmode');
%system(['cp ',ffdatadir, 'BaseFlow.txt ',ffdatadir, 'MeanFlow_guess.txt']);
%system(['cp ',ffdatadir, 'Eigenmode.txt ',ffdatadir, 'SelfConsistentMode_guess.txt']);
%    mycp([ffdatadir, 'BaseFlow.txt'],[ffdatadir, 'MeanFlow_guess.txt']);
%    mycp([ffdatadir, 'Eigenmode.txt'],[ffdatadir, 'SelfConsistentMode_guess.txt']);
%elseif(meanflow.datatype=='MeanFlow')
%    mydisp(1,'### Self Consistent : with guess from MeanFlow/SCMode');
%system(['cp ',ffdatadir, 'MeanFlow.txt ',ffdatadir, 'MeanFlow_guess.txt']);
%system(['cp ',ffdatadir, 'SelfConsistentMode.txt ',ffdatadir, 'SelfConsistentMode_guess.txt']);
%    mycp([ffdatadir, 'MeanFlow.txt'],[ffdatadir, 'MeanFlow_guess.txt']);
%    mycp([ffdatadir, 'SelfConsistentMode.txt'],[ffdatadir, 'SelfConsistentMode_guess.txt']);
%else
%    error('wrong type of field for Harmonic balance');
%end

% position input files for the freefem solver...
mycp(meanflow.filename, [ffdatadir, 'MeanFlow_guess.txt']);
mycp(meanflow.filename, [ffdatadir, 'MeanFlow_guess.txt']);
mycp(mode.filename, [ffdatadir, 'SelfConsistentMode_guess.txt']);

if (p.Results.Fyguess ~= -1)
    mydisp(1,['starting with guess Lift force : ', num2str(p.Results.Fyguess)]);
    solvercommand = ['echo ', num2str(p.Results.Re), ' ', num2str(p.Results.omegaguess), ' ', num2str(p.Results.sigma), ...
        ' L ', num2str(p.Results.Fyguess), ' | ', ff, ' ', ffdir, 'SelfConsistentDirect_2D.edp'];
elseif (p.Results.Aguess ~= -1)
    mydisp(1,['starting with guess amplitude (Energy) ', num2str(p.Results.Aguess)]);
    solvercommand = ['echo ', num2str(p.Results.Re), ' ', num2str(p.Results.omegaguess), ' ', num2str(p.Results.sigma), ...
        ' E ', num2str(p.Results.Aguess), ' | ', ff, ' ', ffdir, 'SelfConsistentDirect_2D.edp'];
else
    solvercommand = ['echo ', num2str(p.Results.Re), ' ', num2str(p.Results.omegaguess), ' ', num2str(p.Results.sigma), ...
        ' None  | ', ff, ' ', ffdir, 'SelfConsistentDirect_2D.edp'];
end


status = mysystem(solvercommand);


mydisp(1,['#### Self-Consistent (HB1) CALCULATION COMPLETED with Re = ', num2str(p.Results.Re), ' ; sigma = ', num2str(p.Results.sigma)]);
meanflow = importFFdata(meanflow.mesh, 'MeanFlow.ff2m');
mode = importFFdata(meanflow.mesh, 'SelfConsistentMode.ff2m');

if (meanflow.iter < 0)
    error('ERROR in SF_HarmonicBalance : Newton iteration did not converge')
end

mydisp(1,['#### omega =  ', num2str(imag(mode.lambda))]);
%mydisp(1,['#### A =  ' num2str(mode.A) ]);


end

%if(nargout>0)
%system('cp MeanFlow.txt MeanFlow_guess.txt');
%system('cp chbase_threshold.txt Self_guess.txt');
%end


%if(nargout>1)
%eigenmode=eigenmodeT;
%system('cp Eigenmode_threshold.txt Eigenmode_guess.txt');
%end
