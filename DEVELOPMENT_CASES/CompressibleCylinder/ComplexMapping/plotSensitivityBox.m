% Script to compute a performance test of CM

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;

% parameters for mesh creation 
% Outer Domain 
mesh.xinfm=-40.; mesh.xinfv=80.; mesh.yinf=40.0
type = 'S';
% Creation of a mesh
bf = SmartMesh(type,mesh)

% Configuration of the Complex mapping
Ma = 0.3;
Re = 100;

lambda = 0.11+0.704*1i;

bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',lambda,'nev',1,'type','D','sym','N','Ma',Ma);

mesh.xinfm=-20.; mesh.xinfv=40.; mesh.yinf=20.0
type = 'S';
bf = SmartMesh(type,mesh)

bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',lambda,'nev',1,'sym','N','Ma',Ma);

SF_pyPlot('plotVar',em, 'field', 'ux1', 'plotVar2', em,...
          'field2', 'p1', 'xlim', [-20,40],...
          'ylim', [-20,20], 'cmap', 'RdBu',...
          'BoxCMOrig', [-10,-10], 'BoxCMUpperCor', [30,20], 'BoxCM', '1',...
          'type_complex', 'imag', 'levelsFilled', [-0.00001,0.00001],...
          'levelsFilled2', [-0.01,0.01]);

