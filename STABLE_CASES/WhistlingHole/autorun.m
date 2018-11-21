function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the case WhistlingHole
%
% USAGE : 
% autorun(0) -> automatic check
% autorun(1) -> produces the figures used for the manual
% autorun(2) -> may produces "bonus" results...
%%
close all;
run('../../SOURCES_MATLAB/SF_Start.m');verbosity=10;
system('mkdir FIGURES');
figureformat = 'png';

if(nargin==0) 
    isfigures=0; verbosity=0;
end;
value =0;

%% Test 1 : base flow

bf = SmartMesh_Hole_MeshM2;

disp(['Test 1 : delta P : ', bf.Pup]);
PupREF = 0.9118;

error1 = abs(bf.Pup/PupREF-1)

if(error1>1e-3) 
    value = value+1 
end

if(isfigures>0)
   %
end


%% Test 2 : Impedance

omega = 2.5;
Re = 1600; chi=1;
foC = SF_LinearForced(bf,omega);
disp(['Test 2 : impedance = ', num2str(foC.Z)]);
ZREF = -2.4887-2.6083i;

error2 = abs(foC.Z/ZREF-1)
if(error2>1e-3) 
    value = value+1 
end

%% Test 3 : Eigenvalue

omega = 2.5;
Re = 1600; chi=1;
[ev,em2D] = SF_Stability(bf,'shift',-2.09i+.08,'m',0,'nev',10,'type','D','solver','StabAxi_COMPLEX_m0.edp');


disp(['Test 3 : eigenvalue = ', num2str(ev(1))]);
evREF = 0.0106 - 2.0688i;
error3 = abs(ev(1)/evREF-1)

if(error3>1e-3) 
    value = value+1 
end


end
