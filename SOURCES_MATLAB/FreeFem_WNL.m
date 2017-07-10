function wnl = FreeFem_WNL(baseflow);
%
% Matlab/FreeFem driver for computation of weakly nonlinear expansion
% This is part of the StabFem project, version 2.1, july 2017, D. Fabre
%
% usage : wnl = FreeFem_WNL();
%    return is a structure with fields wnl.lambda, wnl.mu, wnl.a, etc..
%
global ff ffdir
[status]=system([ff ' ' ffdir 'WeaklyNonLinear_Axi.edp']);
wnl = importFFdata(baseflow.mesh,'WNL_results.ff2m');
end



