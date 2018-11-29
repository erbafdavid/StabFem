%SF_Start
run('../../SOURCES_MATLAB/SF_Start.m');

disp(['Importing data from an old simulation']);
% Load mesh based on eigenmode simulation with domain 80x80
load('../BirdCallComplex/MESH80x80DIRECT/Figure4.mat')
% Duplicate interesting variables (modes)
em1BranchListH1 = em1BranchListH;
em2BranchListH1 = em2BranchListH;
em3BranchListH1 = em3BranchListH;
em4BranchListH1 = em4BranchListH;

%% PLOT DIRECT MODE

set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
set(0,'defaultAxesFontSize',26)


% Plot of p1 at different Reynolds and modes
disp(['Plotting p1 for each mode']);
load('../BirdCallComplex/MESH30x30DIRECT/figure4.mat')

scrsz = get(0, 'ScreenSize');


fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em1BranchListH1(1),'p1','ColorBar','out','ColorRange',[-1e-4,1e-4],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on
SF_Plot(em4BranchListH(1),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.01);
nameFigure = ['Mode1Re1600.pdf'];
export_fig(['figures/pdf/',nameFigure]) 

    
fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em2BranchListH1(1),'p1','ColorBar','out','ColorRange',[-1e-5,1e-5],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on
SF_Plot(em2BranchListH(1),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.1);
nameFigure = ['Mode2Re1600.pdf'];
export_fig(['figures/pdf/',nameFigure]) 

    
fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em3BranchListH1(1),'p1','ColorBar','out','ColorRange',[-1e-5,1e-5],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on 
SF_Plot(em3BranchListH(1),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.05);
nameFigure = ['Mode3Re1600.pdf'];
export_fig(['figures/pdf/',nameFigure]) 

    
fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em4BranchListH1(1),'p1','ColorBar','out','ColorRange',[-1e-5,1e-5],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on 
SF_Plot(em1BranchListH(1),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.1);
nameFigure = ['Mode4Re1600.pdf'];
export_fig(['figures/pdf/',nameFigure]) 


fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em1BranchListH1(end),'p1','ColorBar','out','ColorRange',[-4e-3,4e-3],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on 
SF_Plot(em1BranchListH(end),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.05);
nameFigure = ['Mode1Re320.pdf'];
export_fig(['figures/pdf/',nameFigure]) 


fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em2BranchListH1(end),'p1','ColorBar','out','ColorRange',[-2e-3,2e-3],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on 
SF_Plot(em2BranchListH(end),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.05);
nameFigure = ['Mode2Re320.pdf'];
export_fig(['figures/pdf/',nameFigure]) 


fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em3BranchListH1(end),'p1','ColorBar','out','ColorRange',[-2e-4,2e-4],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on 
SF_Plot(em3BranchListH(end),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.01);
nameFigure = ['Mode3Re640.pdf'];
export_fig(['figures/pdf/',nameFigure]) 


fig = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(em4BranchListH1(end),'p1','ColorBar','out','ColorRange',[-5e-5,5e-5],...
        'ColorMap','redblue','Boundary','on',...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off');
axes('Position',[.62 .62 .2 .2])
box on 
SF_Plot(em4BranchListH(end),'p1','ColorBar','out',...
        'ColorMap','redblue','Boundary','on','XLim',[-1,10],'YLim',[0,4],...
        'BDLabels', [3,4,5,6], 'BDColors', 'k', 'Mesh', 'off','logsat',0.001);
nameFigure = ['Mode4Re1200.pdf'];
export_fig(['figures/pdf/',nameFigure]) 

close all;