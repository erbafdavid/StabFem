clear all; clc;

run('../SOURCES_MATLAB/SF_Start.m');
verbosity = 20;

close all;

% generating initial mesh
bf = SF_Init('Mesh.edp',[]);

% plot
bf.mesh.xlim=[-5,10];bf.mesh.ylim=[-8,8];
plotFF(bf,'ux');



system('ff-mpirun -np 2 Newton_2D_Comp.edp'); 
bf = importFFdata(bf.mesh,'BaseFlow.ff2m');
plotFF(bf,'ux');
% This first basic integration works, FANTASTICO !


%% to be incorporated in the general SF_Baseflow driver
% remain to find the way to pass the parameters in paralel mpi operation
% and then to do the stability 

% 17 may 2018 has been an extremely productive day !

% GRANDE FLAVIO !
 



