%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%          -- X = 3 / Da = 1e-9 / Om = 0 / Eps = 0.95 --
%                                                   
%#####################################################################

clear all;
close all;
clc

%% 0 - Préchauffage

run('../SOURCES_MATLAB/SF_Start.m');

ff = 'FreeFem++ -v 0';
ffdatadir = 'WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational
figureformat = 'png';

verbosity = 10;

%% 1 - Génération MAILLAGE et BASEFLOW

Rx = 3;

% Géométrie
Rayon = 1;
Diametre = 2*Rayon;
Epaisseur = 1/(2*Rx);
Xmin = -20*Rayon;
Xmax = 50*Rayon;
Ymax = 20*Rayon;

boxx = [-Epaisseur/2, Epaisseur/2, Epaisseur/2, -Epaisseur/2, -Epaisseur/2];
boxy = [0, 0, Rayon, Rayon, 0];

% SF_Init
baseflow=SF_Init('mesh_Disk.edp',[Diametre Epaisseur Xmin Xmax Ymax]);

% Plot mesh initial
figure;
plotFF(baseflow,'mesh','Title',['Maillage initial du domaine de calcul'],'Xlabel',['x'],'Ylabel',['r']);
hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;

%% 2 - Génération du BASEFLOW pour un certain Re

% Paramètres de calcul
%Re_start = [10 50 100 150 200 250];
Omega = [0.];
Darcy = [1e-9];
Porosite = [0.95];

baseflow = SF_BaseFlow(baseflow,'Re',10,'Omegax',Omega,'Darcy',Darcy,'Porosity',Porosite);
baseflow = SF_BaseFlow(baseflow,'Re',50);
baseflow = SF_BaseFlow(baseflow,'Re',80);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
baseflow = SF_BaseFlow(baseflow,'Re',100);
baseflow = SF_BaseFlow(baseflow,'Re',130);
baseflow = SF_BaseFlow(baseflow,'Re',150);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
baseflow = SF_BaseFlow(baseflow,'Re',170);
baseflow = SF_BaseFlow(baseflow,'Re',200);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',0.5);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',0.5);

%------------------

% Plot mesh final
figure;
baseflow.xlabel=('x');baseflow.ylabel=('r');
plotFF(baseflow,'mesh','title',['Maillage final du domaine de calcul'],'Xlabel',['x'],'Ylabel',['r']);
hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;

% Plot ux
figure;
baseflow.xlabel=('x');baseflow.ylabel=('r');
plotFF(baseflow,'ux','Contour','on','CLevels',[0,1],'Title',['Champ de vitesse u_x pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'Xlabel',['x'],'Ylabel',['r']);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot ur
figure;
plotFF(baseflow,'ur','Title',['Champ de vitesse u_r pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'Xlabel',['x'],'Ylabel',['r']);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot uphi
figure;
plotFF(baseflow,'uphi','title',['Champ de vitesse u_\phi pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'Xlabel',['x'],'Ylabel',['r']);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot P
figure;
plotFF(baseflow,'p','title',['Champ de pression P pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'Xlabel',['x'],'Ylabel',['r']);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot Vorticité
figure;
plotFF(baseflow,'vort','title',['Champ de vorticité \omega pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'Xlabel',['x'],'Ylabel',['r']);
hold on;plot(boxx, boxy, 'w-');hold off;

% % Plot Lignes de courant
% figure;
% plotFF(baseflow,'psi','Contour','on','Levels',50,'title',['Lignes de courant pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'Xlabel',['x'],'Ylabel',['r']);
% hold on;plot(boxx, boxy, 'w-');hold off;

%% 3 - Spectrum exploration


% first exploration for m=1
[ev1,em1] = SF_Stability(baseflow,'m',1,'shift',1-1i,'nev',10,'PlotSpectrum','yes');
[ev2,em2] = SF_Stability(baseflow,'m',1,'shift',1,'nev',10,'PlotSpectrum','yes');
[ev3,em3] = SF_Stability(baseflow,'m',1,'shift',1+1i,'nev',10,'PlotSpectrum','yes');

% Plot EV_ux
figure;
plotFF(em,'ux1','title',['Champ de vitesse u_x pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula');
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot EV_uy
figure;
plotFF(em,'uy1','title',['Champ de vitesse u_y pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula');
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot EV_p
figure;
plotFF(em,'p1','title',['Champ de pression P pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula');
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot EV_Vort
figure;
plotFF(em,'vort1','title',['Champ de vorticité \omega pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula');
hold on;plot(boxx, boxy, 'w-');hold off;

figure;
plot(real(ev1),imag(ev1),'+',real(ev2),imag(ev2),'+',real(ev3),imag(ev3),'+');
title(['spectrum for m=1, Re=' num2str(baseflow.Re) ', Omega=' num2str(Omega) ', Porosity=' num2str(Porosite)])

%% 4 - Sability curves

Re_LIN = [80 : -2 : 50];

baseflow=SF_BaseFlow(baseflow,'Re',100);
[ev,em] = SF_Stability(baseflow,'m',1,'shift',ev,'nev',1);
lambda1_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda1_LIN = [lambda1_LIN ev];
    end    

% baseflow=SF_BaseFlow(baseflow,'Re',100);
% [ev,em]=SF_Stability(baseflow,'m',1,'shift',ev2(1),'nev',1);
% lambda2_LIN=[];
%     for Re = Re_LIN
%         baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
%         lambda2_LIN = [lambda2_LIN ev];
%     end   
%     
% baseflow=SF_BaseFlow(baseflow,'Re',100);
% [ev,em]=SF_Stability(baseflow,'m',1,'shift',ev3(1),'nev',1);
% lambda3_LIN=[];
%     for Re = Re_LIN
%         baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
%         lambda3_LIN = [lambda3_LIN ev];
%     end   

figure();
plot(Re_LIN,real(lambda1_LIN),'b+-');
xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
% box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% set(gca,'FontSize', 18);
saveas(gca,'PorousDisk_sigma_Re',figureformat);

figure();hold off;
plot(Re_LIN,imag(lambda1_LIN));
xlabel('Re');ylabel('$\omega$','Interpreter','latex');
% box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% set(gca,'FontSize', 18);
saveas(gca,'PorousDisk_omega_Re',figureformat);    
