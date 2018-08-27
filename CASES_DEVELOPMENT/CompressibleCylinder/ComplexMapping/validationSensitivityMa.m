% Script to compute different properties of the cylinder with CM

if (exist('CriticalReynolds') ~= 1)
    clear all;
    % close all;
    run('../../../SOURCES_MATLAB/SF_Start.m');
    figureformat='png'; AspectRatio = 0.56; % for figures
    tinit = tic;
    verbosity=20;
    CriticalReynolds = 0;
end


% parameters for mesh creation 
% Outer Domain 
mesh.xinfm=-40.; mesh.xinfv=80.; mesh.yinf=40.0
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=30.;y2=10;
% Sponge extension
ls=0.01; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=100; % Refinement density around the cylinder
n1=7; % Density in the inner domain
n2=3; % Density in the middle domain
ns=0.15; % Density in the outer domain
nsponge=.15; % density in the sponge region

% parameters for mesh creation 
% This parameter is used if sponge is selected
method.alpha = 0.0;
% Either Complex mapping (CM) or Sponge (S)
method.name = 'CM';
% symmetric (1) or full domain (2)
method.symm = 2;
% 0 indicates antisymmetry for the mode, 1 symmetry, 2 full domain
method.symmEig = 2;
% Coefficients of the complex mapping, to determine La, Lc and gammac for 
% each mapping (negative x-Xn, postive x-Xp and positive y-Yp)
% Compute mesh without complex mapping
CM.BoxXpCoeff = 1.2;
CM.BoxXnCoeff = -1.3;
CM.BoxYpCoeff = 1.15;
CM.LaXpCoeff = 1.01;
CM.LaXnCoeff = 1.01;
CM.LaYpCoeff = 1.01;
CM.LcXpCoeff = 0.4;
CM.LcXnCoeff = 0.5;
CM.LcYpCoeff = 0.35;
CM.gcXpCoeff = 0.0;
CM.gcXnCoeff = 1.0;
CM.gcYpCoeff = 0.0;

myWriteMethod(CM,mesh,method);

% Ma = 0.1 Linear
Ma = 0.1;
omegac = 0.7272;
Rec = 46.94;
MeshBased = 'D'; % Used for mesh refinement
meshRef = 2.75
% Mesh generation
bf = SF_Init('Mesh.edp',[mesh.xinfm,mesh.xinfv,mesh.yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',meshRef);
if (MeshBased == 'S')
    bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
    [evD,emD] = SF_Stability(bf,'shift',omegac*i,'nev',1,'type','S','sym','A','Ma',Ma);
    emD.filename='./WORK/Sensitivity.txt';
    emD.datastoragemode='ReP2';
    bf=SF_AdaptMesh(bf,emD,'Hmax',meshRef);
    bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
    [evD,emD] = SF_Stability(bf,'shift',0.046 + 0.745i,'nev',1,'type','S','sym','A','Ma',Ma);
    emD.filename='./WORK/Sensitivity.txt';
    emD.datastoragemode='ReP2';
    bf=SF_AdaptMesh(bf,emD,'Hmax',meshRef);
    [evD,emD] = SF_Stability(bf,'shift',0.046 + 0.745i,'nev',1,'type','D','sym','A','Ma',Ma);
else
   [evCr,emCr] = SF_Stability(bf,'shift',omegac*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
   [evD,emD] = SF_Stability(bf,'shift',0.046+0.745*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_AdaptMesh(bf,emD,emCr,'Hmax',meshRef);
end

% Compute linear analysis
% Coefficients of the complex mapping, to determine La, Lc and gammac for 
% each mapping (negative x-Xn, postive x-Xp and positive y-Yp)
CM.BoxXpCoeff = 0.5;
CM.BoxXnCoeff = -0.4;
CM.BoxYpCoeff = 0.4;
CM.LaXpCoeff = 1.845;
CM.LaXnCoeff = 1.845;
CM.LaYpCoeff = 1.845;
CM.LcXpCoeff = 0.3;
CM.LcXnCoeff = 0.3;
CM.LcYpCoeff = 0.3;
CM.gcXpCoeff = -0.3;
CM.gcXnCoeff = -0.1;
CM.gcYpCoeff = -0.1;
myWriteMethod(CM,mesh,method);


% Determine Re_c for each Ma

em_L = [];
Omega_c = [0.731]; % Guess
Rec = [46.5]; % Guess
Ma_Range = [0.1:0.05:0.6];
sizeL = size(Ma_Range);
sizeL = sizeL(2);

Rec(1) = 46.5; % Initial guess for the first Ma
ev = -0.01+Omega_c(1)*1i; % Initial guess to get into the loop
if (CriticalReynolds ~= 1)
    for index=[1:sizeL]
       Ma = Ma_Range(index);
       Re = Rec(index); % Initial guess for iteration index
       omegac =  Omega_c(index); % Initial guess for iteration index
       lambda = omegac*1i; % Initial guess for iteration index
       while(real(ev) < 0)
               bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
               [evD,emD] = SF_Stability(bf,'shift', lambda,'nev',1,'type','D','sym','N','Ma',Ma);
               Re = Re+0.5;
               evPrev = ev;
               ev = evD;
               lambda = 2*ev-evPrev; % Next guess 
       end
       Rec(index) = (Re-1.0) + .5/(real(ev)-real(evPrev))*(-real(evPrev));
       Omega_c(index) = imag(evPrev) + (imag(ev)-imag(evPrev))/(real(ev)-real(evPrev))*(-real(evPrev))
       Omega_c(index+1) = Omega_c(index); % Guess for the next
       Rec(index+1) = Rec(index) % Guess for the next
       ev = -0.005 + Omega_c(index+1)*1i; % Next guess
    end
    CriticalReynolds = 1;
end

varMa = [];
for index=[1:sizeL]
   Ma = Ma_Range(index);
   Re = Rec(index);
   omegac =  Omega_c(index);
   bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
   [evS,emS] = SF_Stability(bf,'shift', + omegac*1i,'nev',1,'type','D','sym','N','Ma',Ma);
   Ma = Ma+0.05;
   bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
   if(index<sizeL)
       omegac =  Omega_c(index+1);
   else
       omegac = omegac + (Omega_c(index-1) - Omega_c(index-2));
   end
   [evS2,emS2] = SF_Stability(bf,'shift', + omegac*1i,'nev',1,'type','D','sym','N','Ma',Ma);
   em_L = [em_L, emS];
   varMaDir = evS2 - evS;
   varMa = [varMa, varMaDir];
end

save('SensitivityVali.mat');

em_WNL = [];
meanflow_WNL = [];
mode_WNL = [];
for index=[11:sizeL]
   Ma = Ma_Range(index);
   Re = Rec(index);
   omegac =  Omega_c(index);
   bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
   [ev,em] = SF_Stability(bf,'shift', + omegac*1i,'nev',1,'type','S','sym','N','Ma',Ma);
   [wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',Re+0.3,'Normalization','V'); % Here to generate a starting point for the next chapter
   em_WNL = [em_WNL, wnl];
   meanflow_WNL = [meanflow_WNL, meanflow];
   mode_WNL = [mode_WNL, mode];
end

save('WNLCM.mat');
