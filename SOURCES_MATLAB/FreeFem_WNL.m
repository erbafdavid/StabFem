function wnl = FreeFem_WNL(baseflow);
%
% Matlab/FreeFem driver for computation of weakly nonlinear expansion
% This is part of the StabFem project, version 2.1, july 2017, D. Fabre
%
% usage : wnl = FreeFem_WNL(baseflow);
%    return is a structure with fields wnl.lambda, wnl.mu, wnl.a, etc..
%
global ff ffdir ffdatadir sfdir 

if(strcmp(ffdatadir,'./DATA_FREEFEM_BIRDCALL_ERCOFTAC')==0) % in future we should manage this in a better way
    [status]=system([ff ' ' ffdir 'WeaklyNonLinear_Axi.edp']);
else 
    [status]=system([ff ' ' ffdir 'WeaklyNonLinear_BirdCall.edp']);
end

wnl = importFFdata(baseflow.mesh,'WNL_results.ff2m');


