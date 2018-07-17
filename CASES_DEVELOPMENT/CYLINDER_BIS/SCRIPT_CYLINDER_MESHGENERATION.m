%  Instability of the wake of a cylinder with STABFEM  
%
%  this script demonstrates the main fonctionalities of StabFem for the
%  reference case of the wake of a cylinder.
%  1/ Generation of an adapted mesh 

%  3/ Stability curves St(Re) and sigma(Re) for Re = [40-100]
%  4/ Determination of the instability threshold and Weakly-Nonlinear
%  analysis
%  5/ Harmonic-Balance for Re = REc-100
%  6/ Self-consistent model for Re=100

% CHAPTER 0 : set the global variables needed by the drivers

run('../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures


    
bf=SF_Init('Mesh_Cylinder.edp',[-40 80 40]);
bf=SF_BaseFlow(bf,'Re',1);
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_Adapt(bf,'Hmax',5);
disp(' ');
disp('mesh adaptation to SENSITIVITY : ')
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type','S');
[bf,em]=SF_Adapt(bf,em,'Hmax',10);

plotFF(bf,'mesh');


