%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%          -- X = 3 / Da = 1e-6 / Om = 0 / Eps = 0.95 --
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

if(exist('WORK/MESHES/mesh_adapt_Re150.txt')==2)
    disp('Mesh/BF already available');
    ffmesh = importFFmesh('./WORK/MESHES/mesh_adapt_Re150.msh');
    baseflow = importFFdata(ffmesh,'./WORK/MESHES/BaseFlow_adapt_Re150.txt');
else
    disp('creating/adapting Mesh/BF') 
     bf = SmartMesh_Porous_Rotating_Disk;
end

%clf(figure(100));
[ev1,em1] = SF_Stability(baseflow,'m',m,'shift',EV(1),'nev',10,'PlotSpectrum','yes');
[ev2,em2] = SF_Stability(baseflow,'m',m,'shift',EV(2),'nev',10,'PlotSpectrum','yes');
[ev3,em3] = SF_Stability(baseflow,'m',m,'shift',conj(EV(1)),'nev',10,'PlotSpectrum','yes');

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
        [ev1,em1] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda1_LIN = [lambda1_LIN ev1];
    end

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
        [ev2,em2] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda2_LIN = [lambda2_LIN ev2];
    end

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
toc;