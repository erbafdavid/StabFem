% Script to compute different properties of the cylinder with CM

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;


% parameters for mesh creation 
% Outer Domain 
mesh.xinfm=-20.; mesh.xinfv=200.; mesh.yinf=20.0
% Inner domain
x1m=-2.5; x1v=30.; y1=2.5;
% Middle domain
x2m=-10.;x2v=40.;y2=10;
% Sponge extension
ls=300.0; 
% Refinement parameters
n=2; % Vertical density of the outer domain
ncil=100; % Refinement density around the cylinder
n1=8; % Density in the inner domain
n2=6; % Density in the middle domain
ns=2; % Density in the outer domain
nsponge=.15; % density in the sponge region

bf = SF_Init('Mesh.edp',[mesh.xinfm,mesh.xinfv,mesh.yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
Ma = 0.3;
Re = 100
lambda =  0.11+0.685*1i

bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
[evS,emS] = SF_Stability(bf,'shift',lambda,'nev',1,'sym','N','Ma',Ma);

save('TestForReflectingWaves.mat')
