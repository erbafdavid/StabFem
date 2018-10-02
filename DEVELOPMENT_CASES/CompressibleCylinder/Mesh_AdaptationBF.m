clear all; clc;
run('../SOURCES_MATLAB/SF_Start.m');
verbosity = 20;
close all;


% parameters for mesh creation 
% Outer Domain 
xinfm=-50.; xinfv=100.; yinf=50.;
% Inner domain
x1m=-5.; x1v=20.; y1=2.5;
%  Middle domain
x2m=-15.;x2v=40.;y2=10;
% Sponge extension
ls=300; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=50; % Refinement density around the cylinder
n1=5; % Density in the inner domain
n2=3; % Density in the middle domain
ns=0.3; % Density in the outer domain
nsponge=0.05; % density in the sponge region
% 1 if the mesh is created in matlab, 0 otherwise.
mesh_completed = 0;
plotting = 1;

% generating initial mesh
if (mesh_completed ~= 1)
    bf = SF_Init('Mesh.edp',[xinfm,xinfv,yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
    Re = 60;
    Ma = 0.5;
    bf = SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1);
    [ev,em] = SF_Stability(bf,'shift',shift,'nev',1,'type','D','sym','N','Ma',Ma);

    bf=SF_Adapt(bf,'Hmax',5);
    mesh_completed = 1;
    %Plotting mesh
    if (plotting == 1)
        plotFF(bf,'mesh');
        title('Initial mesh (full size)');
        box on; %pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
        set(gca,'FontSize', 18);
        %saveas(gca,'Mesh_Full',figureformat); 
    end
end
% plot





% TO BE TESTED IN PARALLEL (I have some issues with my install, and I can 
% only run it in serial.

%system('ff-mpirun -np 2 Newton_2D_Comp.edp'); Function importFFdata : reading complex(1) field : lambdaVarBF = 8.2008e-06+1.7857e-06i

%bf = import=====================================================
%plotFF(bf,'ux');
% This first basic integration works, FANTASTICO !






