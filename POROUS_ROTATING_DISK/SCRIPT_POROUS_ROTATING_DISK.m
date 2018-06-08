%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%               -- ANALYSE DE STABILITÉ GLOBALE --
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%                                                   
%#####################################################################

clear all;
close all;
clc

%% 0 - Préchauffage

run('../SOURCES_MATLAB/SF_Start.m');

ffdatadir = 'WORK\'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational
figureformat = 'png';

verbosity = 100;

%% 1 - Génération MAILLAGE et BASEFLOW

% Géométrie
Diametre = 1;
    DIAMETER = num2str(Diametre);
Epaisseur = 0.333;
    THICKNESS = num2str(Epaisseur);
Xmin = -20;
    XMIN = num2str(Xmin);
Xmax = 40;
    XMAX = num2str(Xmax);
Ymax = 20;
    YMAX = num2str(Ymax);

boxx = [-Epaisseur/2, Epaisseur/2, Epaisseur/2, -Epaisseur/2, -Epaisseur/2];
boxy = [0, 0, Diametre/2, Diametre/2, 0];

baseflow=SF_Init('mesh_Disk.edp',[DIAMETER ' ' THICKNESS ' ' XMIN ' ' XMAX ' ' YMAX]);

% Plot mesh
baseflow.xlim = [Xmin Xmax]; baseflow.ylim=[0,Ymax];
baseflow.xlabel=('x');baseflow.ylabel=('r');
baseflow.plottitle = ['Maillage du domaine de calcul'];
plotFF(baseflow,'mesh');
hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;

%% 2 - Génération du BASEFLOW pour un certain Re

baseflow = SF_BaseFlow(baseflow,'Re',10,'Porosity',1e-3,'Omegax',0.);
baseflow = SF_Adapt(baseflow,'Hmax',2);
baseflow = SF_BaseFlow(baseflow,'Re',30);
baseflow = SF_BaseFlow(baseflow,'Re',60);
baseflow = SF_Adapt(baseflow,'Hmax',2);
baseflow = SF_BaseFlow(baseflow,'Re',100);
baseflow = SF_BaseFlow(baseflow,'Re',150);
baseflow = SF_Adapt(baseflow,'Hmax',2);
baseflow = SF_BaseFlow(baseflow,'Re',200);
baseflow = SF_Adapt(baseflow,'Hmax',2);

%Plot ux
baseflow.xlim = [Xmin Xmax]; baseflow.ylim=[0,Ymax];
baseflow.xlabel=('x');baseflow.ylabel=('r');
baseflow.plottitle = ['Champ de vitesse u_x pour Re = ' num2str(baseflow.Re)];
plotFF(baseflow,'ux','Contour','on');
hold on;plot(boxx, boxy, 'w-');hold off;

%Plot ur
baseflow.plottitle = ['Champ de vitesse u_r pour Re = ' num2str(baseflow.Re)];
plotFF(baseflow,'ur','Contour','on');
hold on;plot(boxx, boxy, 'w-');hold off;

%Plot uphi
baseflow.plottitle = ['Champ de vitesse u_\phi pour Re = ' num2str(baseflow.Re)];
plotFF(baseflow,'uphi','Contour','on');
hold on;plot(boxx, boxy, 'w-');hold off;

%Plot p
baseflow.plottitle = ['Champ de pression P pour Re = ' num2str(baseflow.Re)];
plotFF(baseflow,'p','Contour','on');
hold on;plot(boxx, boxy, 'w-');hold off;

%Plot vorticité
baseflow.plottitle = ['Champ de vorticité \omega pour Re = ' num2str(baseflow.Re)];
plotFF(baseflow,'vort','Contour','on');
hold on;plot(boxx, boxy, 'w-');hold off;

% %% Chapter 2 : Spectrum exploration
% 
% % first exploration for m=1
% [ev1,em1] = SF_Stability(baseflow,'m',1,'shift',0.2-.6i,'nev',10);%,'PlotSpectrum','yes');
% [ev2,em2] = SF_Stability(baseflow,'m',1,'shift',0.2,'nev',10);
% [ev3,em3] = SF_Stability(baseflow,'m',1,'shift',0.2+.6i,'nev',10);
% plot(real(ev1),imag(ev1),'+',real(ev2),imag(ev2),'+',real(ev3),imag(ev3),'+');
% title('spectrum for m=1, Re=200, Omega=0.1, Porosity=0.001')
% 
% % Chapter 3 : stability curves
% 
% Re_LIN = [200 : 2.5: 220];
% 
% baseflow=SF_BaseFlow(baseflow,'Re',200);
% [ev,em] = SF_Stability(baseflow,'m',1,'shift',ev1(1),'nev',1);
% lambda1_LIN=[];
%     for Re = Re_LIN
%         baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
%         lambda1_LIN = [lambda1_LIN ev];
%     end    
% 
% baseflow=SF_BaseFlow(baseflow,'Re',200);
% [ev,em]=SF_Stability(baseflow,'m',1,'shift',ev2(1),'nev',1);
% lambda2_LIN=[];
%     for Re = Re_LIN
%         baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
%         lambda2_LIN = [lambda2_LIN ev];
%     end   
%     
% baseflow=SF_BaseFlow(baseflow,'Re',200);
% [ev,em]=SF_Stability(baseflow,'m',1,'shift',ev3(1),'nev',1);
% lambda3_LIN=[];
%     for Re = Re_LIN
%         baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
%         lambda3_LIN = [lambda3_LIN ev];
%     end   
% 
% figure(20);
% plot(Re_LIN,real(lambda1_LIN),'b+-',Re_LIN,real(lambda1_LIN),'r+-',Re_LIN,real(lambda3_LIN),'b+-');
% xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
% % box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% % set(gca,'FontSize', 18);
% saveas(gca,'PorousDisk_sigma_Re',figureformat);
% 
% figure(21);hold off;
% plot(Re_LIN,imag(lambda1_LIN),'b+-',Re_LIN,imag(lambda1_LIN),'r+-',Re_LIN,imag(lambda3_LIN),'b+-');
% xlabel('Re');ylabel('$\omega$','Interpreter','latex');
% % box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% % set(gca,'FontSize', 18);
% saveas(gca,'PorousDisk_omega_Re',figureformat);    
%     