%  Instability of the wake of a cylinder with STABFEM  
%
%  this scripts performs the following calculations :
%  1/ Generation of an adapted mesh
%  2/ Base-flow properties for Re = [2-40]
%  3/ Stability curves St(Re) and sigma(Re) for Re = [40-100]
%  4/ Determination of the instability threshold
%  5/ Harmonic-Balance for Re = REc-100
%  6/ Self-consistent model for Re=100

% CHAPTER 0 : set the global variables needed by the drivers

global ff ffdir ffdatadir sfdir verbosity
%ff = '/PRODCOM/FREEFEM/Ubuntu12.04/3.29/bin/FreeFem++-nw'; % on IMFT network
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw'; % on DF's macbookpro 
ffdatadir = './WORK/';
sfdir = '../SOURCES_MATLAB/'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts
verbosity = 1;
addpath(sfdir);
system(['mkdir ' ffdatadir]);
figureformat='png'; AspectRatio = 0.56; % for figure

%##### CHAPTER 1 : COMPUTING THE MESH WITH ADAPTMESH PROCEDURE

if(exist('baseflow')==1)
disp(' ADAPTMESH PROCEDURE WAS PREVIOUSLY DONE, START WITH EXISTING MESH : '); 
baseflow=SF_BaseFlow(baseflow,60);
[ev,em] = SF_Stability(baseflow,'shift',0.04+0.76i,'nev',1,'type','S');
else
   
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');
disp(' LARGE MESH : [-40:80]x[0:40] ');
disp(' ');    
baseflow=SF_Init('Mesh_Cylinder_Large.edp');
baseflow=SF_BaseFlow(baseflow,1);
baseflow=SF_BaseFlow(baseflow,10);
baseflow=SF_BaseFlow(baseflow,60);
baseflow=SF_Adapt(baseflow,'Hmax',5);
baseflow=SF_Adapt(baseflow,'Hmax',5);
disp(' ');
disp('mesh adaptation to SENSITIVITY : ')
[ev,em] = SF_Stability(baseflow,'shift',0.04+0.76i,'nev',1,'type','S');
[baseflow,em]=SF_Adapt(baseflow,em,'Hmax',10);

end

%%% CHAPTER 4 : determination of critical reynolds number

if(exist('Rec')==1)
    disp('INSTABILITY THRESHOLD ALREADY COMPUTED');
else 
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
baseflow=SF_BaseFlow(baseflow,'Re',50);
[ev,em] = SF_Stability(baseflow,'shift',+.75i,'nev',1,'type','S');
[baseflow,em]=SF_FindThreshold(baseflow,em);
[ev,em] = SF_Stability(baseflow,'shift',+.75i,'nev',1,'type','S');

Rec = baseflow.Re;  Dragc = baseflow.Drag; 
Lxc=baseflow.Lx;    Omegac=imag(em.lambda);
%[ev,em] = SF_Stability(baseflow,'shift',em.lambda,'type','S','nev',1);
end

wnl = SF_WNL(baseflow)

epsilonRANGE = 0:.0001:.005;
ReWNL = 1./(1/Rec-epsilonRANGE);
AWNL = sqrt(real(wnl.Lambda)/real(wnl.nu0+wnl.nu2))*sqrt(epsilonRANGE);
omegaWNL =Omegac+epsilonRANGE.*(imag(wnl.Lambda)-real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2));


figure(21);hold on;
plot(ReWNL,omegaWNL/(2*pi),'g--');hold on;

figure(25);hold on;
plot(ReWNL,AWNL,'g--');


