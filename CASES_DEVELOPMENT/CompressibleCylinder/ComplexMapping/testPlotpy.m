clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;
mesh.xinfm=-40.; mesh.xinfv=100.; mesh.yinf=40.0
bf = SmartMesh('D',mesh)
Ma = 0.3
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',0.11+0.685*1i,'nev',1,'type','D','Ma',Ma);


% Test yourself the plotting capability
SF_pyPlot('plotVar',em, 'plotVar2',em, 'cmap', 'RdBu',...
          'saveOption', '1','name', 'Name', 'typePlot', 'contour');
      