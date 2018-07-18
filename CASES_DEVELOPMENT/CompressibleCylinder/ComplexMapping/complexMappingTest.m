% Test script to show the effects of complex mapping

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;

% parameters for mesh creation 
% This parameters describe the size of the domain 
xinfm=-35.; xinfv=70.; yinf=35;
% This parameter is used if sponge is selected
alpha = 0.0;
% Either Complex mapping (CM) or Sponge (S)
method = 'CM';
% symmetric (1) or full domain (2)
symm = 1;
% 0 indicates antisymmetry for the mode, 1 symmetry, 2 full domain
symmEig = 0;

% Coefficients of the complex mapping, to determine La, Lc and gammac for 
% each mapping (negative x-Xn, postive x-Xp and positive y-Yp)
BoxXpCoeff = 0.2;
BoxXnCoeff = -0.3;
BoxYpCoeff = 0.15;
LaXpCoeff = 1.01;
LaXnCoeff = 1.01;
LaYpCoeff = 1.01;
LcXpCoeff = 0.4;
LcXnCoeff = 0.5;
LcYpCoeff = 0.35;
gcXpCoeff = 0.0;
gcXnCoeff = 1.0;
gcYpCoeff = 0.0;


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

% Ma = 0.1 Linear/WNL analysis
Ma = 0.1
Omegac = 0.7272
Rec = 46.94

% Mesh generation
bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',10);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',10);
[evD,emD] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
bf=SF_AdaptMesh(bf,emD,'Hmax',10);
        
% WNL analysis - This is only to verify that WNL works well with CM
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','A','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.3,'Normalization','V'); % Here to generate a starting point for the next chapter

% Plotting
figure();
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'ux','Contour',[0 0]);
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

%%% PLOTS of WNL predictions

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

figure(20);hold on;
plot(Re_WNL,real(wnl.Lambda)*epsilon2_WNL,'g--','LineWidth',2);hold on;

figure(21);hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--','LineWidth',2);hold on;
xlabel('Re');ylabel('St');

figure(22);hold on;
plot(Re_WNL,Fx_WNL,'g--','LineWidth',2);hold on;
xlabel('Re');ylabel('Fx');

figure(24); hold on;
plot(Re_WNL,abs(Fy_WNL),'g--','LineWidth',2);
xlabel('Re');ylabel('Fy')

figure(25);hold on;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
xlabel('Re');ylabel('AE')


