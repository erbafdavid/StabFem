
%
% IMPORTANT WARNING : THIS PART OF THE CODE IS STILL UNDER DEVELOPMENT
% THIS EXAMPLE SCRIPT IS NOT YET WORKING CORRECTLY !
%


close all;
run('../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';
%%%%%% CHAPTER 0 : creation of initial mesh for cylindrical bridge, L=4

L = 4;
density=20;
 %creation of an initial mesh (with volume corresponding to coalescence of two spherical caps) 
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]);
V = pi*L/2*(1+L^2/12);
ffmesh = SF_Mesh_Deform(ffmesh,'V',V);

Vol0 = ffmesh.Vol; 
figure(1);
plot(ffmesh.xsurf,ffmesh.ysurf);

%%%% CHAPTER 1 : Eigenvalue computation for m=0 and m=1 FOR A CYLINDRICAL BRIDGE
[evm0,emm0] =  SF_Stability(ffmesh,'nu',0.01,'nev',10,'m',0,'sort','SIA');
evm0
[evm1,emm1] =  SF_Stability(ffmesh,'nu',0.01,'nev',10,'m',1,'sort','SIA');
evm1

