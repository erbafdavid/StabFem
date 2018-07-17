close all;
run('../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';
%%%%%% CHAPTER 0 : creation of initial mesh for cylindrical bridge, L=4

a=.3;
density=80;
xi = .32;

ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);

Vol0 = ffmesh.Vol; 
figure(1);
plot(ffmesh.xsurf,ffmesh.ysurf);


%%%% CHAPTER 1 : Eigenvalue computation for m=0 and m=1 FOR A CYLINDRICAL BRIDGE
[evm3,emm3] =  SF_Stability(ffmesh,'nev',20,'m',3,'sort','SIA');


