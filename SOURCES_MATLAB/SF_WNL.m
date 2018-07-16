function [wnl, meanflow, selfconsistentmode, secondharmonicmode] = SF_WNL(baseflow, eigenmode, varargin);
%
% Matlab/FreeFem driver for computation of weakly nonlinear expansion
% This is part of the StabFem project, version 2.1, july 2017, D. Fabre
%
% ONE-OUTPUT usage : wnl = SF_WNL(baseflow , eigenmode, {'param','value'} );
%    output is a structure with fields wnl.lambda, wnl.mu, wnl.a, etc..
%    'baseflow' should be a base-flow structure corresponding to the critical Reynolds
%     number. 'eigenmode' should be the corresponding neutral mode.
%
%  the optional parameters (couple of 'param' and 'value') may comprise :
%   'Normalization'  -> can be 'L' (lift), 'E' (energy of perturbation),
%                       'V' (velocity a one point), or 'none' (no normalization). Default is 'L'.
%   'AdjointType',   -> can be 'dA' for discrete adjoint or 'cA' for continuous adjoint (default 'dA')
%   'Retest'         -> Value of Reynolds number to generate a "guess" for the
%                     SC-HB methods (useful in three-output and four-output usage, see below)
%
% THREE-OUTPUT USAGE : [wnl,meanflow,selconsistentmode] = SF_WNL(baseflow,eigenmode,[option list])
% this will create an estimation of the meanflow and quasilinear mode, for
% instance to initiate the Self-Consistent model. Ideally the value of Retest
% should be slightly above the threshold.
%
% FOUR-OUTPUT USAGE : [wnl,meanflow,selconsistentmode,secondharmonicmode] = SF_WNL(baseflow,eigenmode,[option list])
%
% IMPLEMENTATION :
% according to parameters this generic driver will launch one of the
% following FreeFem programs :
%      WeaklyNonLinear_2D.edp
%      WeaklyNonLinear_Axi.edp
%      ( WeaklyNonLinear_BirdCall.edp : version to be abandonned)
%
% TODO :
%


global ff ffdir ffdatadir sfdir

p = inputParser;
addParameter(p, 'Retest', -1, @isnumeric);
addParameter(p, 'Normalization', 'L');
addParameter(p, 'AdjointType', 'dA');
parse(p, varargin{:});


if (strcmp(baseflow.mesh.problemtype, 'AxiXR') == 1)
    
    if (strcmp(ffdatadir, './DATA_FREEFEM_BIRDCALL_ERCOFTAC') == 0) % in future we should manage this in a better way
        solvercommand = [ff, ' ', ffdir, 'WeaklyNonLinear_Axi.edp'];
    else
        solvercommand = [ff, ' ', ffdir, 'WeaklyNonLinear_BirdCall.edp'];
    end
    
end

if (strcmp(baseflow.mesh.problemtype, '2D') == 1)
    solvercommand = ['echo ', p.Results.Normalization, ' ', p.Results.AdjointType, ' ', num2str(p.Results.Retest), ' | ', ff, ' ', ffdir, 'WeaklyNonLinear_2D.edp '];
end

errormessage = 'Error in SF_WNL.m';
mysystem(solvercommand, errormessage);

wnl = importFFdata(baseflow.mesh, 'WNL_results.ff2m');

if (nargout >= 3 && p.Results.Retest > -1)
    meanflow = importFFdata(baseflow.mesh, 'MeanFlow_guess.ff2m');
    selfconsistentmode = importFFdata(baseflow.mesh, 'SelfConsistentMode_guess.ff2m');
    disp(' Estimating base flow and quasilinear mode from WNL')
    disp(['### Mode characteristics : AE = ', num2str(selfconsistentmode.AEnergy), ' ; Fy = ', num2str(selfconsistentmode.Fy), ' ; omega = ', num2str(imag(selfconsistentmode.lambda))]);
    disp(['### Mean-flow : Fx = ', num2str(meanflow.Fx)]);
end
if (nargout == 4 && p.Results.Retest > -1)
    secondharmonicmode = importFFdata(baseflow.mesh, 'SecondHarmonicMode_guess.ff2m');
    disp(' Estimating SECOND HARMONIC mode from WNL')
    disp(['### Mode characteristics :  Fx = ', num2str(secondharmonicmode.Fx)]);
    
end
