% Test script to show the effects of complex mapping

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;



% parameters for mesh creation 
% Outer Domain 
yinf=35; xinfm=-yinf; xinfv=70.; 
alpha = 0.0;
method = 'CM';
symm = 2;
symmEig = 2;

BoxXpCoeff = 1.5;
BoxXnCoeff = -1.6;
BoxYpCoeff = 1.4;
LaXpCoeff = 1.01;
LaXnCoeff = 1.01;
LaYpCoeff = 1.01;
LcXpCoeff = 0.7;
LcXnCoeff = 0.8;
LcYpCoeff = 0.6;
gcXpCoeff = -0.5;
gcXnCoeff = 0.5;
gcYpCoeff = -0.5;


mysystem(['echo "xinfm= ' num2str(xinfm) '; xinfv= ' num2str(xinfv) ...
          '; yinf= ' num2str(yinf) ';" > SF_Mesh.edp']); 
mysystem(['echo "alpha= ' num2str(alpha) '; method= \"' method ...
    '\"; symmetryBaseFlow= ' num2str(symm)...
    '; symmetryEigenmode= ' num2str(symmEig) ... 
    '; BoxXpCoeff= ' num2str(BoxXpCoeff) ... 
    '; BoxXnCoeff= ' num2str(BoxXnCoeff) ... 
    '; BoxYpCoeff= ' num2str(BoxYpCoeff) ... 
    '; LaXpCoeff= ' num2str(LaXpCoeff) ... 
    '; LaXnCoeff= ' num2str(LaXnCoeff) ... 
    '; LaYpCoeff= ' num2str(LaYpCoeff) ... 
    '; LcXpCoeff= ' num2str(LcXpCoeff) ... 
    '; LcXnCoeff= ' num2str(LcXnCoeff) ... 
    '; LcYpCoeff= ' num2str(LcYpCoeff) ... 
    '; gcXpCoeff= ' num2str(gcXpCoeff) ... 
    '; gcXnCoeff= ' num2str(gcXnCoeff) ... 
    '; gcYpCoeff= ' num2str(gcYpCoeff) ';" > SF_Method.edp']);

% Ma = 0.5 Nonlinear analysis
Ma = 0.1
Omegac = 0.7272
Rec = 46.94

bf = SF_Init('Mesh_NACA0012.edp',[xinfm,xinfv,yinf]);
Re_Mesh = [1000:1000:9000]
for Re=Re_Mesh(5:end)
    bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
    bf=SF_AdaptMesh(bf,'Hmax',1,'InterpError',5e-3);
    bf=SF_AdaptMesh(bf,'Hmax',1,'InterpError',5e-3);
end

Re_Mesh = [28000:1000:30000]
for Re=Re_Mesh(1:end)
    bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
    bf=SF_AdaptMesh(bf,'Hmax',1);
    bf=SF_AdaptMesh(bf,'Hmax',1);
end

Sigma = [0.0:0.05:-0.06]
Omega = [0.01:0.1:50]
OmegaL = []
SigmaL = []
emL = []
for sigma=Sigma
    for omega=Omega
        [ev,em] = SF_Stability(bf,'shift',sigma+omega*i,'nev',1,'type','D','sym','N','Ma',Ma);
        if (iter < 150 && iter ~= -1)
            SigmaL = [SigmaL,real(ev)];
            OmegaL = [OmegaL,imag(ev)];
            emL = [em, emL];
        end
    end
end
[evD,emD] = SF_Stability(bf,'shift',-0.1+0.1*i,'nev',10,'type','D','sym','N','Ma',Ma);



figure();
% plot the base flow
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'ux');
%plotFF(bf,'ux');
str = 'Box $$B_3$$ Baseflow with complex mapping';
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

