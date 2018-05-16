function [wnl,meanflow,selfconsistentmode,secondharmonicmode] = SF_WNL(baseflow,varargin);
%
% Matlab/FreeFem driver for computation of weakly nonlinear expansion
% This is part of the StabFem project, version 2.1, july 2017, D. Fabre
%
% BASIC usage : wnl = SF_WNL(baseflow);
%    return is a structure with fields wnl.lambda, wnl.mu, wnl.a, etc..
%
% Improved usage : [wnl,meanflow,selconsistentmode] = SF_WNL(baseflow,'Retest',Re)
% this will create an estimation of the meanflow and quasilinear mode, for
% instance to initiate the Self-Consistent model. Ideally the value of Retest
% should be slightly above the threshold.
%
% other Improved usage : [wnl,meanflow,selconsistentmode,secondharmonicmode] = SF_WNL(baseflow,'Retest',Re)

global ff ffdir ffdatadir sfdir 

 p = inputParser;
   addParameter(p,'Retest',-1,@isnumeric);
   addParameter(p,'Normalization','L');
   parse(p,varargin{:});


if(strcmp(baseflow.mesh.problemtype,'AxiXR')==1)

if(strcmp(ffdatadir,'./DATA_FREEFEM_BIRDCALL_ERCOFTAC')==0) % in future we should manage this in a better way
    [status]=system([ff ' ' ffdir 'WeaklyNonLinear_Axi.edp']);
else 
    [status]=system([ff ' ' ffdir 'WeaklyNonLinear_BirdCall.edp']);
end

end

if(strcmp(baseflow.mesh.problemtype,'2D')==1)
    
    ['echo  '  p.Results.Normalization ' ' num2str(p.Results.Retest) ' | ' ff ' ' ffdir 'WeaklyNonLinear_2D.edp '  ]
     [status]=system(['echo '  p.Results.Normalization ' ' num2str(p.Results.Retest) ' | ' ff ' ' ffdir 'WeaklyNonLinear_2D.edp '  ]);
end


wnl = importFFdata(baseflow.mesh,'WNL_results.ff2m');

if(nargout>=3 && p.Results.Retest>-1)
meanflow = importFFdata(baseflow.mesh,'MeanFlow_guess.ff2m');
selfconsistentmode=importFFdata(baseflow.mesh,'SelfConsistentMode_guess.ff2m');
disp(' Estimating base flow and quasilinear mode from WNL')
disp([ '### Mode characteristics : AE = ' num2str(selfconsistentmode.AEnergy) ' ; Fy = ' num2str(selfconsistentmode.Fy) ' ; omega = ' num2str(imag(selfconsistentmode.lambda))]); 
disp([ '### Mean-flow : Fx = ' num2str(meanflow.Fx) ]); 
end
if(nargout==4 && p.Results.Retest>-1)
secondharmonicmode=importFFdata(baseflow.mesh,'SecondHarmonicMode_guess.ff2m');
disp(' Estimating SECOND HARMONIC mode from WNL')
disp([ '### Mode characteristics :  Fx = ' num2str(secondharmonicmode.Fx)  ]); 

end




