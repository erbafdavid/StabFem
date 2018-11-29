%SF_Start
run('../../SOURCES_MATLAB/SF_Start.m');

%% PLOT BASEFLOWS
% Set your FILES!
ffmesh = importFFmesh('../BirdCallComplex/MESH30x30DIRECT/MESHES/mesh_adapt10_Re1280_Ma0.05.msh');
bfLoad = ["../BirdCallComplex/MESH30x30DIRECT/BASEFLOWS/BaseFlow_Re320Ma0.05.ff2m",
          "../BirdCallComplex/MESH30x30DIRECT/BASEFLOWS/BaseFlow_Re640Ma0.05.ff2m",
          "../BirdCallComplex/MESH30x30DIRECT/BASEFLOWS/BaseFlow_Re960Ma0.05.ff2m",
          "../BirdCallComplex/MESH30x30DIRECT/BASEFLOWS/BaseFlow_Re1600Ma0.05.ff2m"
         ];
fig = [];
streamLinesVec = [];
% For the loop(number iterations, name of files)
Reynolds = [320,640,960,1600];
nIter = size(bfLoad);
nIter = nIter(1);
% Start loop
for iter=[1:nIter]
    bf = importFFdata(ffmesh,char(bfLoad(iter)));
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
set(0,'defaultAxesFontSize',26)

%% Compute streamlines
disp(['Computing StreamLines at iteration ',num2str(iter)]);

nStream = 20;
nStream2 = 10;
nStreamCoarse = 5;

x0Source1 = -ones(1,nStream);
y0Source1 = linspace(0,5,nStream);

x0Source2 = linspace(0,2,nStreamCoarse);
y0Source2 = 1.5*ones(1,nStreamCoarse);

x0Source3 = linspace(2,4,nStream2);
y0Source3 = 3*ones(1,nStream2);

x0Source4 = linspace(2.1875,2.189,nStreamCoarse);
y0Source4 = 0.417*ones(1,5);

% x0Source8 = 0.08*ones(1,20);
% y0Source8 = linspace(0.48,0.5,20);

x0Source5 = linspace(0.082,0.094,nStream);
y0Source5 = 0.51*ones(1,nStream);

x0Source6 = linspace(0.082,0.11,nStream);
y0Source6 = 0.54*ones(1,nStream);




streamlines = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source1,...,
                                 'StreamlinesY0',y0Source1, 'plot',...,
                                 "no");
                             
streamlines2 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source2,...,
                                 'StreamlinesY0',y0Source2, 'plot',...,
                                 "no");
                             
streamlines3 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source3,...,
                                 'StreamlinesY0',y0Source3, 'plot',...,
                                 "no");
                             
streamlines4 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source4,...,
                                 'StreamlinesY0',y0Source4, 'plot',...,
                                 "no");
                             
streamlines5 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source5,...,
                                 'StreamlinesY0',y0Source5, 'plot',...,
                                 "no");
                             
streamlines6 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source6,...,
                                 'StreamlinesY0',y0Source6, 'plot',...,
                                 "no");
                             
% streamlines7 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source7,...
%                                  'StreamlinesY0',y0Source7, 'plot',"no");

% streamlines8 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source8,...
%                                     'StreamlinesY0',y0Source8, 'plot',"no");
% streamlines9 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source9,...
%                                 'StreamlinesY0',y0Source9, 'plot',"no");

if(iter==1)
    streamLinesVec = [streamlines, streamlines2, streamlines3,...
                      streamlines4, streamlines5, streamlines6];
else   
    streamLinesVec = [streamLinesVec; streamlines, streamlines2, streamlines3,...
                      streamlines4, streamlines5, streamlines6];
end
pause(2);

%% Plotting current field
disp(['Plotting flow at iteration ',num2str(iter)]);

scrsz = get(0, 'ScreenSize');
fig(iter) = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
SF_Plot(bf,'ux','XLim', [-1,3.5], 'YLim', [0,3.5],'ColorBar','north',...
        'ColorMap','fire','Boundary','on',...
        'BDLabels', [1,2,3,4,5,6], 'BDColors', 'k', 'Mesh', 'off',...
        'logsat',0.1);

% streamlines9 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
%             'StreamlinesInput',streamlines9);
% streamlines8 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
%                 'StreamlinesInput',streamlines8);
% streamlines7 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
%                 'StreamlinesInput',streamlines7);
streamlines6 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
                    'StreamlinesInput',streamlines6);
streamlines5 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
                        'StreamlinesInput',streamlines5);
streamlines4 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
                            'StreamlinesInput',streamlines4);
streamlines3 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
                            'StreamlinesInput',streamlines3);
streamlines2 = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
                                'StreamlinesInput',streamlines2);
streamlines = SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
                                'StreamlinesInput',streamlines);
pause(1);
magnifyOnFigure(fig(iter),...
        'units', 'pixels',...
        'magnifierShape', 'ellipse',...
        'initialPositionSecondaryAxes', [1040 525 150 100],...
        'initialPositionMagnifier',     [564 171 20 10],...    
        'mode', 'interactive',...    
        'displayLinkStyle', 'straight',...        
        'edgeWidth', 2,...
        'edgeColor', 'black',...
        'secondaryAxesFaceColor', [0.91 0.91 0.91]);
nameFigure = ['BaseFlow_Re',num2str(Reynolds(iter)),'.pdf'];
export_fig(['figures/pdf/',nameFigure]) 
end
close all;
% 
% for iter=[1:4]
%     bf = importFFdata(ffmesh,char(bfName(iter)));
%     set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
%     set(groot, 'defaultLegendInterpreter','latex');
%     set(0,'defaultAxesFontSize',26)
%     scrsz = get(0, 'ScreenSize');
%     streamlines9 = SF_PlotStreamlines(bf,'StreamlinesX0', x0Source9,...
%                                     'StreamlinesY0',y0Source9, 'plot',"no");
%     streamLines = [streamLinesVec(iter,:), streamlines9];
%     pause(1);
%     fig(iter) = figure('Position', [0.01*scrsz(3), 0.01*scrsz(4), 1.0*scrsz(3), 1.0*scrsz(4)]);
%     SF_Plot(bf,'ux','XLim', [-1,3.5], 'YLim', [0,3.5],'ColorBar','north',...
%         'ColorMap','fire','Boundary','on',...
%         'BDLabels', [1,2,3,4,5,6], 'BDColors', 'k', 'Mesh', 'off',...
%         'logsat',0.1);
%     SF_PlotStreamlines(bf,'plot',"yes", 'compute', "no", ...,
%                        'StreamlinesInput',streamLines);
%     pause(2);
%     magnifyOnFigure(fig(iter),...
%             'units', 'pixels',...
%             'magnifierShape', 'ellipse',...
%             'initialPositionSecondaryAxes', [1040 525 150 100],...
%             'initialPositionMagnifier',     [564 171 20 10],...    
%             'mode', 'interactive',...    
%             'displayLinkStyle', 'straight',...        
%             'edgeWidth', 2,...
%             'edgeColor', 'black',...
%             'secondaryAxesFaceColor', [0.91 0.91 0.91]);
%     nameFigure = ['Figure',num2str(iter),'.eps'];
%     set(gcf,'renderer','Painters')
%     print(nameFigure,'-depsc', '-tiff','-r300','-painters')
% end