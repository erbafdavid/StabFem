<<<<<<< HEAD
clear all;
close all;
clc;
run('../SOURCES_MATLAB/SF_Start.m');

% importation of a mesh and data field 'base flow' 
Ndensity = 50;         % here Ndensity is the only parameter, but we can pass several 
ffmesh=SF_Mesh('Lshape_Mesh.edp','Params',Ndensity);

% plot the mesh and the associated data
ffmesh.plottitle = 'Mesh for L-shape body';
hand = plotFF(ffmesh);
=======
% This script is a basic example which illustrates the main functionalities of the StabFem Software
clear all; close all;
run('../SOURCES_MATLAB/SF_Start.m');ffdatadir = './';

% Generation of the mesh
Ndensity =40;
ffmesh=SF_Mesh('Lshape_Mesh.edp','Params',Ndensity)
plotFF(ffmesh,'title','Mesh for L-shape body');
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_Mesh','png');
>>>>>>> StabFemOriginal/master

% importation and plotting of a real P1 field : temperature
heatS=SF_Launch('Lshape_Steady.edp','Mesh',ffmesh)
plotFF(heatS,'T','title', 'Solution of the steady heat equation on a L-shaped domain');
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_T0','png');

% importation and plotting of data not associated to a mesh : temperature along a line
heatCut = importFFdata('Heat_1Dcut.ff2m')
figure();plot(heatCut.Xcut,heatCut.Tcut);
title('Temperature along a line : T(x,y=0.25)') 
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_T0_Cut','png');

% importation and plotting of a complex P1 field : temperature for unsteady problem
<<<<<<< HEAD
heatU=SF_Launch('Lshape_Unsteady.edp','Params',10,'Mesh',ffmesh,'DataFile','Heat_Unsteady.ff2m')

heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' num2str(heatU.omega) ' : Re(Uc) ' ];
heatU.xlim = [-.5,1.5]; % note the way to specify plot ranges xlim, ylim 
heatU.ylim = [-.5,1.5];
hand = plotFF(heatU,'Tc.re','ColorMap','jet');%plot the real part of a complex

heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' num2str(heatU.omega) ' : Im(Uc) ' ];
hand = plotFF(heatU,'Tc.im','ColorMap','jet');%plot the imag part of a complex
    
heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' num2str(heatU.omega) ' : |grad(Uc)| ' ];
hand = plotFF(heatU,'normTc','ColorMap','jet');
=======
heatU=SF_Launch('Lshape_Unsteady.edp','Params',100,'Mesh',ffmesh,'DataFile','Heat_Unsteady.ff2m')
plotFF(heatU,'Tc.re','contour','Tc.im','title',['Ti: ' char(13) 'real(colors) and imaginary(levels) parts'])
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_Tc','png');

>>>>>>> StabFemOriginal/master
