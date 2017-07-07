function wnl = FreeFem_WNL(baseflow);
% Matlab/FreeFem driver for computation of weakly nonlinear expansion
%
% usage : wnl = FreeFem_WNL();
%    return is a structure with fields wnl.lambda, wnl.mu, wnl.a, etc..
%
global ff ffdir
[status]=system([ff ' ' ffdir 'WeaklyNonLinear_Axi.edp']);
wnl = importFFdata(baseflow.mesh,'WNL_results.ff2m');
end

