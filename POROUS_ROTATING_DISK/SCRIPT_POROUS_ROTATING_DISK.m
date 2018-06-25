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

ffdatadir = 'WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational
figureformat = 'png';

verbosity = 100;

%% 1 - Génération MAILLAGE et BASEFLOW

Rx = 3;

% Géométrie
Rayon = 1;
    DIAMETER = num2str(2*Rayon);
Epaisseur = 1/(2*Rx);
    THICKNESS = num2str(Epaisseur);
Xmin = -20*Rayon;
    XMIN = num2str(Xmin);
Xmax = 50*Rayon;
    XMAX = num2str(Xmax);
Ymax = 20*Rayon;
    YMAX = num2str(Ymax);

boxx = [-Epaisseur/2, Epaisseur/2, Epaisseur/2, -Epaisseur/2, -Epaisseur/2];
boxy = [0, 0, Rayon, Rayon, 0];

it=0;
baseflow=SF_Init('mesh_Disk.edp',[DIAMETER ' ' THICKNESS ' ' XMIN ' ' XMAX ' ' YMAX]);

% Plot mesh initial
% baseflow.xlim = [Xmin Xmax]; baseflow.ylim=[0,Ymax];
baseflow.xlabel=('x');baseflow.ylabel=('r');
baseflow.plottitle = ['Maillage initial du domaine de calcul'];
plotFF(baseflow,'mesh');
hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;

%% 2 - Génération du BASEFLOW pour un certain Re

% Paramètres de calcul
Re_start = [10:50:1000];
Omega = [0.];
Darcy = [1e-1];
Porosite = [1];

    it=it;
    for Re = Re_start
        tic;
        baseflow = SF_BaseFlow(baseflow,'Re',Re,'Omegax',Omega,'Darcy',Darcy,'Porosity',Porosite);
        it = it+1;
        if (it==1) || (mod(it,5) == 0)% && (Re<150)
            baseflow = SF_Adapt(baseflow,'Hmin',1e-6);
            %--- Plot mesh intermediaire
            baseflow.xlabel=('x');baseflow.ylabel=('r');
            baseflow.plottitle = ['Maillage intermediaire it = ' num2str(it) ' du domaine de calcul'];
            plotFF(baseflow,'mesh');
            hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;
        end
        toc;
    end

% Plot mesh final
% baseflow.xlim = [Xmin Xmax]; baseflow.ylim=[0,Ymax];
% baseflow.xlabel=('x');baseflow.ylabel=('r');
% baseflow.plottitle = ['Maillage final du domaine de calcul'];
% plotFF(baseflow,'mesh');
% hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;
% 
% % Plot ux
% % baseflow.xlim = [-2*Rayon 5*Rayon]; baseflow.ylim=[0,2*Rayon];
% baseflow.xlabel=('x');baseflow.ylabel=('r');
% baseflow.plottitle = ['Champ de vitesse u_x pour Re = ' num2str(baseflow.Re)];
% plotFF(baseflow,'ux','Contour','on','Levels',[0,1e-50]);
% hold on;plot(boxx, boxy, 'w-');hold off;
% 
% % Plot ur
% baseflow.plottitle = ['Champ de vitesse u_r pour Re = ' num2str(baseflow.Re)];
% plotFF(baseflow,'ur');
% hold on;plot(boxx, boxy, 'w-');hold off;
% 
% % Plot uphi
% baseflow.plottitle = ['Champ de vitesse u_\phi pour Re = ' num2str(baseflow.Re)];
% plotFF(baseflow,'uphi');
% hold on;plot(boxx, boxy, 'w-');hold off;
% 
% % Plot P
% baseflow.plottitle = ['Champ de pression P pour Re = ' num2str(baseflow.Re)];
% plotFF(baseflow,'p');
% hold on;plot(boxx, boxy, 'w-');hold off;
% 
% % Plot Vorticité
% baseflow.plottitle = ['Champ de vorticité \omega pour Re = ' num2str(baseflow.Re)];
% plotFF(baseflow,'vort');
% hold on;plot(boxx, boxy, 'w-');hold off;
% 
% % Plot Lignes de courant
% baseflow.plottitle = ['Lignes de courant pour Re = ' num2str(baseflow.Re)];
% plotFF(baseflow,'psi','Contour','on','Levels',10);
% hold on;plot(boxx, boxy, 'w-');hold off;


% %% Chapter 2 : Spectrum exploration
% 
% % first exploration for m=1
% [ev1,em1] = SF_Stability(baseflow,'m',1,'shift',0-.6i,'nev',10,'PlotSpectrum','yes');
% [ev2,em2] = SF_Stability(baseflow,'m',1,'shift',0,'nev',10,'PlotSpectrum','yes');
% [ev3,em3] = SF_Stability(baseflow,'m',1,'shift',0+.6i,'nev',10,'PlotSpectrum','yes');
% 
% figure;
% plot(real(ev1),imag(ev1),'+',real(ev2),imag(ev2),'+',real(ev3),imag(ev3),'+');
% title(['spectrum for m=1, Re=' num2str(baseflow.Re) ', Omega=' num2str(Omega) ', Porosity=' num2str(Porosite)])

%% Chapter 3 : stability curves

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
% figure();
% plot(Re_LIN,real(lambda1_LIN),'b+-',Re_LIN,real(lambda1_LIN),'r+-',Re_LIN,real(lambda3_LIN),'b+-');
% xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
% % box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% % set(gca,'FontSize', 18);
% saveas(gca,'PorousDisk_sigma_Re',figureformat);
% 
% figure();hold off;
% plot(Re_LIN,imag(lambda1_LIN),'b+-',Re_LIN,imag(lambda1_LIN),'r+-',Re_LIN,imag(lambda3_LIN),'b+-');
% xlabel('Re');ylabel('$\omega$','Interpreter','latex');
% % box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% % set(gca,'FontSize', 18);
% saveas(gca,'PorousDisk_omega_Re',figureformat);    
