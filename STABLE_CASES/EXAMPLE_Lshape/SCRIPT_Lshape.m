% This script is a basic example which illustrates the main functionalities of the StabFem Software
clear all; close all;
run('../../SOURCES_MATLAB/SF_Start.m');ffdatadir = './';verbosity=100;
mkdir('FIGURES');

% Generation of the mesh
Ndensity =40;
ffmesh=SF_Mesh('Lshape_Mesh.edp','Params',Ndensity)
figure();plotFF(ffmesh,'title','Mesh for L-shape body');
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_Mesh','png');

pause

% importation and plotting of a real P1 field : temperature
heatS=SF_Launch('Lshape_Steady.edp','Mesh',ffmesh)
figure();plotFF(heatS,'T','title', 'Solution of the steady heat equation on a L-shaped domain');
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_T0','png');

pause

% importation and plotting of data not associated to a mesh : temperature along a line
heatCut = importFFdata('Heat_1Dcut.ff2m')
figure();plot(heatCut.Xcut,heatCut.Tcut);
title('Temperature along a line : T(x,y=0.25)');
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_T0_Cut','png');

pause

% importation and plotting of a complex P1 field : temperature for unsteady problem
heatU=SF_Launch('Lshape_Unsteady.edp','Params',100,'Mesh',ffmesh,'DataFile','Heat_unsteady.ff2m')
figure();plotFF(heatU,'Tc.re','contour','Tc.im','cstyle','patchdashedneg','colormap','redblue','title',{'Ti: ' , 'real(colors) and imaginary(levels) parts'})
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_Tc','png');

% Extracting data along a line

% Here is how to do data extraction in Matlab using the SF_ExtractData function
Ycut = 0.25;Xcut = [0:.01:1];
TIcut = SF_ExtractData(heatU,'Tc',Xcut,Ycut);
figure();plot(Xcut,real(TIcut),'r-',Xcut,imag(TIcut),'b--');

% Here is how to do data extraction directly in the FreeFem program and import the corresponding data from a .txt file (see Lshape_Unsteady.edp). 
heatCutI = importFFdata('HeatU_1Dcut.ff2m');

hold on;plot(heatCut.Xcut,real(heatCutI.Tcut),'k:',heatCutI.Xcut,imag(heatCutI.Tcut),'g:');
title({'Unsteady temperature along a line : T(x,y=0.25)', 'Re and Im parts'} );
set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_T0_Cut','png');
hold on;
