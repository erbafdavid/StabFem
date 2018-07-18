clear all; clc;
run('../../../SOURCES_MATLAB/SF_Start.m');
verbosity = 20;
close all;


% parameters for mesh creation 
% Outer Domain 
xinfm=-50.; xinfv=100.; yinf=50.;
% Middle domain
x1m=-5.; x1v=30.; y1=2.5;
% Inner domain
x2m=-15.;x2v=50.;y2=10;
% Sponge extension
ls=300; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=125; % Refinement density around the cylinder
n1=8; % Density in the inner domain
n2=4; % Density in the middle domain
ns=0.2; % Density in the outer domain
nsponge=0.05; % density in the sponge region
% 1 if the mesh is created in matlab, 0 otherwise.
mesh_completed = 0;
plotting = 1;

% Simulation parameters
Re = 60;
Ma = 0.5;
shift = 0.0288+0.71i;

Meshes_size = [[-50,100,60,-5,17,2.5,-15,40,10,300,n,ncil,n1,n2,ns,nsponge],
               [-50,100,60,-5,17,2.5,-15,40,10,300,n,ncil,2.*n1,1.5*n2,ns,nsponge],
               [-80,150,120,-5,25,3,-20,65,15,400,n,ncil,n1,n2,ns,nsponge],
               [-80,150,120,-5,25,3,-20,65,15,400,n,ncil,1.5*n1,1.2*n2,ns,nsponge],
               [-100,175,140,-5,25,3,-25,80,18,500,n,ncil,n1,n2,ns,nsponge],
               [-100,200,150,-7,30,3.5,-30,100,20,500,n,ncil,n1,n2,ns,nsponge],
               [-100,200,150,-7,30,3.5,-30,100,20,500,n,ncil,1.2*n1,1.2*n2,ns,nsponge],
               [-100,200,150,-7,30,3.5,-30,100,20,500,n,ncil,1.2*n1,1.2*n2,ns,nsponge],
               [-50,100,70,-7,30,3.5,-30,5,20,300,n,1.3*ncil,n1,n2,ns,nsponge]];
ev = []; % array of eigenvalues used to determine the mesh convergence
em = [];
Fx_BF = [];
Lx_BF = [];
Lbx_BF = [];
Lby_BF = [];
for i = 1:size(Meshes_size)
    disp("Starting mesh extension and refiment convergence ");
    disp(i+" meshes out of "+ size(Meshes_size)+" studied");
    bf = SF_Init('Mesh.edp',Meshes_size(i,:));
    bf = SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1);
    [evi,emi] = SF_Stability(bf,'shift',shift,'nev',1,'type','D','sym','N','Ma',Ma);
    ev(i) = evi;
    Fx_BF = [Fx_BF,bf.Fx];
    Lx_BF = [Lx_BF,bf.Lx];
    Lbx_BF = [Lbx_BF,bf.Lbx];
    Lby_BF = [Lby_BF,bf.Lby];
    disp("Mesh number" + i + " checked");
end