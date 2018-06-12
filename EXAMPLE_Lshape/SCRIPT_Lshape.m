
% This script is a basic example which illustrates the main functionalities
% of the StabFem Software


clear all;
close all;
run('../SOURCES_MATLAB/SF_Start.m');

% importation of a mesh and data field 'base flow' 
Ndensity =40;
% here Ndensity is the only parameter, but we can pass several 
ffmesh=SF_Mesh('Lshape_Mesh.edp','Params',Ndensity);


% plot the mesh and the associated data
ffmesh.plottitle = 'Mesh for L-shape body';
hand = plotFF(ffmesh);

% importation and plotting of a real P1 field : temperature
heatS=SF_Launch('Lshape_Steady.edp','Mesh',ffmesh)
heatS.plottitle = 'Solution of the steady heat equation on a L-shaped domain';
plotFF(heatS,'T');

% importation and plotting of data not associated to mesh : temperature along a line
heatCut = importFFdata('Heat_1Dcut.ff2m');
figure(3);
plot(heatCut.Xcut,heatCut.Tcut);
title('Temperature along a line : T(x,y=0.25)') 

% importation and plotting of a complex P1 field : temperature for unsteady problem
heatU=SF_Launch('Lshape_Unsteady.edp','Params',10,'Mesh',ffmesh,'DataFile','Heat_Unsteady.ff2m')

heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' num2str(heatU.omega) ' : Re(Uc) ' ];
heatU.xlim = [-.5,1.5]; % note the way to specify plot ranges xlim, ylim 
heatU.ylim = [-.5,1.5];
hand = plotFF(heatU,'Tc.re');%plot the real part of a complex

heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' num2str(heatU.omega) ' : Im(Uc) ' ];
hand = plotFF(heatU,'Tc.im');%plot the imag part of a complex
    
heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' num2str(heatU.omega) ' : |grad(Uc)| ' ];
hand = plotFF(heatU,'normTc');
    

