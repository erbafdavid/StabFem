%% This script is a basic example on the usage of "adaptation masks"

%% Initialization
clear all; close all;
run('../../SOURCES_MATLAB/SF_Start.m');ffdatadir = './';verbosity=0;
mkdir('FIGURES');

%% Generation of the mesh
Ndensity =100;
ffmesh=SF_Mesh('Lshape_Mesh.edp','Params',Ndensity)

%% Compute and plot the "Mask" function
Mask = SF_Launch('AdaptationMask.edp','Type','rectangle','Params',[.1 .4 .1 .4 .02],'Mesh',ffmesh,'DataFile','Mask.ff2m')
subplot(2,2,1);
SF_Plot(Mask,'Maskx.re');
subplot(2,2,2);
SF_Plot(Mask,'Maskx.im');
subplot(2,2,3);
SF_Plot(Mask,'Masky.re');
subplot(2,2,4);
SF_Plot(Mask,'Masky.im');
suptitle('Adaptation mask functions')

pause(1);

%% Compute and plot the solution of a thermal problem 
heatU=SF_Launch('Lshape_Unsteady.edp','Params',1000,'Mesh',ffmesh,'DataFile','Heat_unsteady.ff2m')
figure();SF_Plot(heatU,'Tc.re','colormap','redblue','title','solution of thermal boundary-layer problem');

%% Performs mash adaptation accroding to this mask and the solution to the model problem
ffmesh2 = SF_Adapt(ffmesh,heatU,'Hmax',.1,'Hmin',1e-6);
ffmesh3 = SF_Adapt(ffmesh,Mask,'Hmax',.1,'Hmin',1e-6)
ffmesh4 = SF_Adapt(ffmesh,Mask,heatU,'Hmax',.1,'Hmin',1e-6);


figure;
subplot(2,2,1); SF_Plot(ffmesh,'title','initial mesh');
subplot(2,2,2); SF_Plot(ffmesh2,'title','adapted to Field');
subplot(2,2,3); SF_Plot(ffmesh3,'title','adapted to Mask');
subplot(2,2,4); SF_Plot(ffmesh4,'title','adapted to Field+Mask');
