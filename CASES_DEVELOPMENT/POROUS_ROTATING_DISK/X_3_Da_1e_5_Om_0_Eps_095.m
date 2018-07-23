%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%          -- X = 3 / Da = 1e-5 / Om = 0 / Eps = 0.95 --
%                                                   
%#####################################################################

clear all;
close all;
clc

tic;

%% 0 - Préchauffage

run('../../SOURCES_MATLAB/SF_Start.m');
addpath(sfdir);

ff = 'FreeFem++ -nw -v 0';
ffdatadir = 'WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational
figureformat = 'png';

verbosity = 10;

%% 1 - Génération MAILLAGE et BASEFLOW

Rx = 3;

% Géométrie
Diametre = 1;
Rayon = Diametre/2;
Epaisseur = 1/(2*Rx);
Xmin = -20*Rayon;
Xmax = 100*Rayon;
Ymax = 20*Rayon;

global boxx boxy;
boxx = [-Epaisseur/2, Epaisseur/2, Epaisseur/2, -Epaisseur/2, -Epaisseur/2];
boxy = [0, 0, Rayon, Rayon, 0];

baseflow = SF_Init('mesh_Disk.edp',[Diametre Epaisseur Xmin Xmax Ymax]);

% Plot mesh initial
figure;
plotFF(baseflow,'mesh','Title','Maillage initial du domaine de calcul');
xlabel('x');ylabel('r');
hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;

% Creation et vidange de PROFILS/
if (exist([ffdatadir, 'PROFILS']) ~= 7)
    mymake([ffdatadir, 'PROFILS/']);
else
    myrm([ffdatadir, 'PROFILS/*']);
end

%% 2 - Génération du BASEFLOW - Re = 150

% Paramètres de calcul
Omega = 0.;
Darcy = 1e-5;
Porosite = 0.95;

% Baseflow Re=150
baseflow = SF_BaseFlow(baseflow,'Re',10,'Omegax',Omega,'Darcy',Darcy,'Porosity',Porosite);
baseflow = SF_BaseFlow(baseflow,'Re',50);
baseflow = SF_BaseFlow(baseflow,'Re',70);
baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',5);
baseflow = SF_BaseFlow(baseflow,'Re',80);
baseflow = SF_BaseFlow(baseflow,'Re',100);
baseflow = SF_BaseFlow(baseflow,'Re',130);
baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',5);
baseflow = SF_BaseFlow(baseflow,'Re',150);
baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',5);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',5);

%% 3 - Spectrum exploration #1 

% first exploration for m=1
m = 1;

EVm1 = [0.0133-0.7157i 0.0513 0.0133+0.7157i];
type = 'D'; % essayer S ou D
[EVm1(1),em] = SF_Stability(baseflow,'m',1,'shift',EVm1(1),'nev',1,'type',type);

baseflow = SF_Adapt(baseflow,em,'Hmin',1e-5,'Hmax',5);

clf(figure(100));
[ev1,em1] = SF_Stability(baseflow,'m',1,'shift',EVm1(1),'nev',10,'PlotSpectrum','yes');
[ev2,em2] = SF_Stability(baseflow,'m',1,'shift',EVm1(2),'nev',10,'PlotSpectrum','yes');
[ev3,em3] = SF_Stability(baseflow,'m',1,'shift',conj(EVm1(1)),'nev',10,'PlotSpectrum','yes');

figure;
plot(real(ev1),imag(ev1),'+',real(ev2),imag(ev2),'+',real(ev3),imag(ev3),'+');
title(['Spectrum for m=' num2str(m) ' - Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)])
xlabel('\sigma_r');
ylabel('\sigma_i');

%% 4 - Sability curves #1 

vp = 0;

% Mode instationnaire
vp = vp+1;
Re_LIN1 = [150 : -0.5 : 145];
baseflow=SF_BaseFlow(baseflow,'Re',Re_LIN1(1));
[ev1,em1] = SF_Stability(baseflow,'m',1,'shift',ev1(1),'nev',1);
baseflow = SF_Adapt(baseflow,em1,'Hmin',1e-5);
lambda1_LIN=[];
    for Re = Re_LIN1
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev1,em1] = SF_Stability(baseflow,'nev',1,'shift','cont');
        [ev1,em1] = SF_Stability(baseflow,'m',1,'shift',ev1,'nev',1);
        lambda1_LIN = [lambda1_LIN ev1];
    end

[ReCIm1,evIm1,emIm1,baseflow] = ReCritique(baseflow,Re_LIN1,lambda1_LIN,m,1);

figure();
subplot(2,1,1);
    hold on;
    ax = gca;
    ax.XAxisLocation = 'origin';
    plot(Re_LIN1,real(lambda1_LIN),'bx-');
    xlabel('Re');ylabel('\sigma_r');
    title(['Taux d''amplification pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    %saveas(gca,['.\Resultats\VP\TA_Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax)],figureformat);
    hold off;
subplot(2,1,2);
    hold on;
    plot(Re_LIN1,imag(lambda1_LIN),'rx-');
    xlabel('Re');ylabel('\sigma_i');
    title(['Fréquence d''oscillation pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    saveas(gca,['.\Resultats\VP\Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax) '__' num2str(vp)],figureformat);
    hold off;

% Mode stationnaire
vp = vp+1;
Re_LIN2 = [140 : -0.5 : 135];
baseflow=SF_BaseFlow(baseflow,'Re',Re_LIN2(1));
[ev2,em2] = SF_Stability(baseflow,'m',1,'shift',ev2(1),'nev',1);
baseflow = SF_Adapt(baseflow,em2,'Hmin',1e-5);
lambda2_LIN=[];
    for Re = Re_LIN2
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev2,em2] = SF_Stability(baseflow,'nev',1,'shift','cont');
        [ev2,em2] = SF_Stability(baseflow,'m',1,'shift',ev2,'nev',1);
        lambda2_LIN = [lambda2_LIN ev2];
    end
    
[ReCSm1,evSm1,emSm1,baseflow] = ReCritique(baseflow,Re_LIN2,lambda2_LIN,m,1);

figure();
subplot(2,1,1);
    hold on;
    ax = gca;
    ax.XAxisLocation = 'origin';
    plot(Re_LIN2,real(lambda2_LIN),'bx-');
    xlabel('Re');ylabel('\sigma_r');
    title(['Taux d''amplification pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    %saveas(gca,['.\Resultats\VP\TA_Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax)],figureformat);
    hold off;
subplot(2,1,2);
    hold on;
    plot(Re_LIN2,imag(lambda2_LIN),'rx-');
    xlabel('Re');ylabel('\sigma_i');
    title(['Fréquence d''oscillation pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    saveas(gca,['.\Resultats\VP\Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax) '__' num2str(vp)],figureformat);
    hold off;

%% 5 - BASEFLOW - Re = 255

baseflow = SF_BaseFlow(baseflow);
baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',5);
baseflow = SF_BaseFlow(baseflow,'Re',180);
baseflow = SF_BaseFlow(baseflow,'Re',200);
baseflow = SF_BaseFlow(baseflow,'Re',230);
baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',5);

%% 6 - Spectrum exploration #2 

% second exploration for m=2
m = 2;

EVm2 = [0.0397-0.7949i 0.0139 0.0397+0.7949i];
type = 'D'; % essayer S ou D
[EVm2(1),em] = SF_Stability(baseflow,'m',2,'shift',EVm2(1),'nev',1,'type',type);

baseflow = SF_Adapt(baseflow,em,'Hmin',1e-5,'Hmax',5);

clf(figure(100));
[ev1,em1] = SF_Stability(baseflow,'m',2,'shift',EVm2(1),'nev',10,'PlotSpectrum','yes');
[ev2,em2] = SF_Stability(baseflow,'m',2,'shift',EVm2(2),'nev',10,'PlotSpectrum','yes');
[ev3,em3] = SF_Stability(baseflow,'m',2,'shift',conj(ev1(1)),'nev',10,'PlotSpectrum','yes');

figure;
plot(real(ev1),imag(ev1),'+',real(ev2),imag(ev2),'+',real(ev3),imag(ev3),'+');
title(['Spectrum for m=' num2str(m) ' - Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)])
xlabel('\sigma_r');
ylabel('\sigma_i');

%% 7 - Sability curves #2

vp = 0;

% Mode instationnaire
vp = vp+1;
Re_LIN1 = [220 : -0.5 : 215];
baseflow=SF_BaseFlow(baseflow,'Re',Re_LIN1(1));
[ev1,em1] = SF_Stability(baseflow,'m',2,'shift',ev1(1),'nev',1);
baseflow = SF_Adapt(baseflow,em1,'Hmin',1e-5);
lambda1_LIN=[];
    for Re = Re_LIN1
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev1,em1] = SF_Stability(baseflow,'m',2,'shift',ev1,'nev',1);
        lambda1_LIN = [lambda1_LIN ev1];
    end

[ReCIm2,evIm2,emIm2,baseflow] = ReCritique(baseflow,Re_LIN1,lambda1_LIN,m,1);

figure();
subplot(2,1,1);
    hold on;
    ax = gca;
    ax.XAxisLocation = 'origin';
    plot(Re_LIN1,real(lambda1_LIN),'bx-');
    xlabel('Re');ylabel('\sigma_r');
    title(['Taux d''amplification pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    %saveas(gca,['.\Resultats\VP\TA_Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax)],figureformat);
    hold off;
subplot(2,1,2);
    hold on;
    plot(Re_LIN1,imag(lambda1_LIN),'rx-');
    xlabel('Re');ylabel('\sigma_i');
    title(['Fréquence d''oscillation pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    saveas(gca,['.\Resultats\VP\Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax) '__' num2str(vp)],figureformat);
    hold off;

% Mode stationnaire
vp = vp+1;
Re_LIN2 = [230 : -1 : 225];
baseflow=SF_BaseFlow(baseflow,'Re',Re_LIN2(1));
[ev2,em2] = SF_Stability(baseflow,'m',2,'shift',ev2(1),'nev',1);
baseflow = SF_Adapt(baseflow,em2,'Hmin',1e-5);
lambda2_LIN=[];
    for Re = Re_LIN2
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev2,em2] = SF_Stability(baseflow,'m',2,'shift',ev2,'nev',1);
        lambda2_LIN = [lambda2_LIN ev2];
    end
    
[ReCSm2,evSm2,emSm2,baseflow] = ReCritique(baseflow,Re_LIN2,lambda2_LIN,m,1);

figure();
subplot(2,1,1);
    hold on;
    ax = gca;
    ax.XAxisLocation = 'origin';
    plot(Re_LIN2,real(lambda2_LIN),'bx-');
    xlabel('Re');ylabel('\sigma_r');
    title(['Taux d''amplification pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    %saveas(gca,['.\Resultats\VP\TA_Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax)],figureformat);
    hold off;
subplot(2,1,2);
    hold on;
    plot(Re_LIN2,imag(lambda2_LIN),'rx-');
    xlabel('Re');ylabel('\sigma_i');
    title(['Fréquence d''oscillation pour Re=' num2str(baseflow.Re) ' - Da=' num2str(baseflow.Darcy) ' - \Omega=' num2str(baseflow.Omegax) ', \epsilon=' num2str(baseflow.Porosity)]);
    saveas(gca,['.\Resultats\VP\Re_' num2str(baseflow.Re) '_Da_' num2str(baseflow.Darcy) '_Om_' num2str(baseflow.Omegax) '__' num2str(vp)],figureformat);
    hold off;

%##################################################"
%% RESULTATS

Da = Darcy;
Om = Omega;
Rec = [ReCIm1 ReCSm1];% ReCIm2 ReCSm1];
EVc = [evIm1 evSm1];% evIm2 evSm2];

save(['.\Resultats\VP\X3_Da' num2str(Da) '_Om' num2str(Om) '.mat'],'Da','Om','Rec','EVc');

%##################################################"
toc;