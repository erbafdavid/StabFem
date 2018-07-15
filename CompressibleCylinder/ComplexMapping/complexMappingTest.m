% Test script to show the effects of complex mapping

clear all;
% close all;
run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;



% parameters for mesh creation 
% Outer Domain 
xinfm=-35.; xinfv=70.; yinf=35;
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=40.;y2=10;
% Sponge extension
ls=0.1; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=80; % Refinement density around the cylinder
n1=8; % Density in the inner domain
n2=3; % Density in the middle domain
ns=0.2; % Density in the outer domain
nsponge=.2; % density in the sponge region
alpha = 0.0;
method = 'CM';
symm = 1;
symmEig = 0;

mysystem(['echo "xinfm= ' num2str(xinfm) '; xinfv= ' num2str(xinfv) ...
          '; yinf= ' num2str(yinf) ';" > SF_Mesh.edp']); 
mysystem(['echo "alpha= ' num2str(alpha) '; method= \"' method ...
    '\"; symmetryBaseFlow= ' num2str(symm)...
    '; symmetryEigenmode= ' num2str(symmEig) ';" > SF_Method.edp']);

% Ma = 0.5 Nonlinear analysis
Ma = 0.5
Omegac = 0.6945
Rec = 49.15

bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',1);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',1);
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',3);



bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','S','sym','A','Ma',Ma);


figure();
% plot the base flow for Re = 60
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'ux','Contour','on','Levels',[0 0]);
%plotFF(bf,'ux');
str = 'Box $$B_3$$ Baseflow without complex mapping';
title(str,'Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);

figure();
% plot the eigenmode for Re = Rec
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1Adj');
str = ' Adjoint Eigenmode with $$\gamma_c = 1.0$$';
title(str,'Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);

figure();
% plot the eigenmode for Re = Rec
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1');
str = 'Eigenmode with $$\gamma_c = 0.0$$';
title(str,'Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);

% plot the mesh (full size)
figure()
plotFF(bf,'mesh');
str = 'Refined mesh';
title(str,'Interpreter','latex');box on; %pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh_Full',figureformat); 