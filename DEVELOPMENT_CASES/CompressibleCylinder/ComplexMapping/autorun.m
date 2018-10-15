function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the wake of a cylinder with STABFEM  
%  - Base flow computation
%  - Linear stability
%  - WNL
%
% USAGE : 
% autorun -> automatic check (non-regression test). 
% Result "value" is the number of unsuccessful tests
% autorun(1) -> produces the figures (in present case not yet any figures)

run('../../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
myrm('WORK/*')
myrm('WORK/*/*')

if(nargin==0) 
    isfigures=0; verbosity=0;
end;

format long;
%% Chapter 0 : reference values for non-regression tests
np_REF = 4190;
Fx_REF =  0.556271000000000;
ev_REF =   0.112721000000000 + 0.713545000000000i

Rec_REF =   46.8127;
Lxc_REF =    3.37898;
Omegac_REF =    0.730699;

Lambda_REF = 8.443160000000001 + 2.318750000000000i;
nu0_REF = 3.581560000000000e+01 - 1.237380000000000e+02i;
nu1_REF = 2.155400000000000 - 4.661610000000000i;
nu2_REF = -0.024923200000000 + 0.401719000000000i;   

% Creation of mesh
mesh.xinfm=-20.; mesh.xinfv=40.; mesh.yinf=20.0
type = 'S';
bf = SmartMesh(type,mesh,'MeshRefine',5)

value = 0;
disp('##### autorun test 1 : mesh and BASE FLOW');
error1 = abs(bf.Fx/Fx_REF-1)+abs(bf.mesh.np-np_REF-1)
if(error1>1e-3) 
    value = value+1 
end

%%  CHAPTER 2 : linear mode for Re=100


disp('##### autorun test 2 : LINEAR MODE');
bf=SF_BaseFlow(bf,'Re',100,'Mach',0.3,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',0.11+0.704*1i,'nev',1,'type','D');


error2 = abs(ev/ev_REF-1);
if(error2>1e-3) 
    value = value+1 
end

%% Chapter 3 : Threshold

ReList = [46.7 46.9];
evList = [];
for Re=ReList
    bf=SF_BaseFlow(bf,'Re',Re,'Mach',0.3,'type','NEW');
    [ev,em] = SF_Stability(bf,'shift',+0.728*1i,'nev',1,'type','D');
    evList = [evList ev];
    if(real(ev) > 0)
        Res = (Re-0.2) + real(ev)*0.2/(real(ev) - real(evList(end-1)) );
    end
end

bf=SF_BaseFlow(bf,'Re',Res,'Mach',0.3,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',+0.728*1i,'nev',1,'type','D');

Rec = bf.Re;
Lxc=bf.Lx;   
Omegac=imag(em.lambda);

error3 = abs(Rec/Rec_REF-1)+abs(Lxc/Lxc_REF-1)+abs(Omegac/Omegac_REF-1)
if(error3>1e-3) 
    value = value+1;
end

%% Chapter 4 : solve WNL model and uses it to generate a guess for Res (just above the threshold)
disp('##### autorun test 4 : WNL');

[ev,em] = SF_Stability(bf,'shift',ev,'nev',1,'type','S'); % type S = direct+adjoint (adjoint is needed for WNL)
[wnl,meanflow,mode,mode2] = SF_WNL(bf,em,'Retest',Res,'Mach',0.3);

wnl.Lambda
wnl.nu0
wnl.nu2

error4 = abs(wnl.Lambda/Lambda_REF-1)+abs(wnl.nu0/nu0_REF-1)+abs(wnl.nu2/nu2_REF-1)
if(error4>1e-3) 
    value = value+1
end

end