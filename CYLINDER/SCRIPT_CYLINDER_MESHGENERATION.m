%  Instability of the wake of a cylinder with STABFEM  
%
%  this script demonstrates the main fonctionalities of StabFem for the
%  reference case of the wake of a cylinder.
%  1/ Generation of an adapted mesh 


% CHAPTER 0 : set the global variables needed by the drivers

run('../SOURCES_MATLAB/SF_Start.m');verbosity = 10;

figureformat='png'; AspectRatio = 0.56; % for figures

% Chapter 1 : generation of an adapted mesh
    
bf=SF_Init('Mesh_Cylinder.edp',[-40 80 40]);
bf=SF_BaseFlow(bf,'Re',1);
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_Adapt(bf,'Hmax',1);
disp(' ');
disp('mesh adaptation to SENSITIVITY : ')

figure();plotFF(bf,'ux','xlim',[-2 5],'ylim',[0 3]);
pause


[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type','S');
bf=SF_Adapt(bf,em,'Hmax',1);
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type','S');

bf.xlim = [-2 4]; bf.ylim=[0,3];
figure();plotFF(bf,'ux','xlim',[-2 4],'ylim',[0 3]);
figure();plotFF(bf,'mesh','xlim',[-4 10],'ylim',[0 6]);

[bf,em]=SF_FindThreshold(bf,em)



