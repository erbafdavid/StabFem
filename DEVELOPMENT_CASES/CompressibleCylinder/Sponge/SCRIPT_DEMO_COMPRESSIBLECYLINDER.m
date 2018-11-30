
%% CHAPTER 0 : set the global variables needed by the drivers

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;

% parameters for mesh creation 
% Outer Domain 
xinfm=-40.; xinfv=80.; yinf=40.;
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=30.;y2=10;
% Sponge extension
ls=300.0; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=100; % Refinement density around the cylinder
n1=7; % Density in the inner domain
n2=3; % Density in the middle domain
ns=0.15; % Density in the outer domain
nsponge=.15; % density in the sponge region


%% Mesh & BF creation
Ma = 0.2;
Re = 150;

disp(' '); 
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');
%bf = SF_Init('Mesh_Cylinder.edp',[-80 80 40]);
%bf = SF_BaseFlow(mesh,'Re',1,'Mach',0.2);
mesh = SF_Mesh('Mesh_HalfDomain.edp','Params',[-100,100,100,200,.1,60]);
bf=SF_BaseFlow(mesh,'Re',1,'Mach',0.2);

bf=SF_BaseFlow(bf,'Re',60,'Mach',0.2);
bf = SF_Adapt(bf,'Hmax',10);
%[ev,emS,emD,emA] = SF_Stability(bf,'shift',0.044 + 0.728i,'nev',1,'type','S','sym','N'); % NB PROBLEM in type='A' mode
%bf = SF_Adapt(bf,emS,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',150,'Mach',0.2);
[ev,emD] = SF_Stability(bf,'shift',0.152 + 0.642i,'nev',1,'type','D','sym','N'); % NB PROBLEM in type='A' mode
bf = SF_Adapt(bf,emD,'Hmax',10);
%bf = SF_Split(bf);

%% Plot base flow (figure 2 of Fani et al)
figure();    
% plot the base flow for Re = 60
SF_Plot(bf,'ux','xlim',[-5 15],'ylim',[0 5]);
title('Base flow at Re=150 (axial velocity)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_BaseFlowRe60Ma02',figureformat);

%% Plot eigenmode (figure 6 of Fani et al)
[ev,emS,emD,emA] = SF_Stability(bf,'shift',0.152 + 0.642i,'nev',1,'type','S','sym','N'); 

figure;
SF_Plot(emD,'p1','xlim',[-100 100],'ylim',[-100 100],'colorrange',[-1e-7,1e-7],'colormap','redblue');

figure;
SF_Plot(emD,'ux1','xlim',[-2 5],'ylim',[0 3],'colorrange','cropcentered','colormap','redblue');
