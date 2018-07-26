%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%                     -- Test Lx et Fx --
%                        -- X = 3 --
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

verbosity = 10;

%% 1 - Génération MAILLAGE et BASEFLOW

Rx = 3;

% Géométrie
Diametre = 1;
Rayon = Diametre/2;
Epaisseur = 1/(2*Rx);
Xmin = -20*Rayon;
Xmax = 50*Rayon;
Ymax = 20*Rayon;

boxx = [-Epaisseur/2, Epaisseur/2, Epaisseur/2, -Epaisseur/2, -Epaisseur/2];
boxy = [0, 0, Rayon, Rayon, 0];

%% 2 - Génération du BASEFLOW pour un certain Re

Lx = [];
Fx = [];
Darcyy = [];
Rei = 0;
Re = [10];
Darcy = [logspace(-9,-5,40) logspace(-5,0,100)];

Omega = [0.];
Porosite = [0.95];

for Ref = Re
    Rei = Rei+1;
    Dai = 0;
    itt = 0;
    baseflow = SF_Init('mesh_Disk.edp',[Diametre Epaisseur Xmin Xmax Ymax]);
    for Reff = [10:20:Ref]
        baseflow = SF_BaseFlow(baseflow,'Re',Reff,'Omegax',Omega,'Darcy',Darcy(1),'Porosity',Porosite);
        itt=itt+1;
        if ((itt==1) || (mod(itt,3)==0))
            baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',0.5);
        end
        if (Reff==Ref)
            baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',0.5);
        end
    end
    if (Reff==Ref)
        for Darcyf = Darcy
            Darcyy = [Darcyy Darcyf];
            Dai = Dai+1;
            baseflow = SF_BaseFlow(baseflow,'Re',Reff,'Omegax',Omega,'Darcy',Darcyf,'Porosity',Porosite);
            baseflow = SF_Adapt(baseflow,'Hmin',1e-5,'Hmax',0.5);
            disp(' ')
            disp('***********  ECRITURE  ***********')
            disp(' ')
            disp([' Itération n° ' num2str(length(Lx)) '/' num2str(length(Darcy))])
            Lx(Rei,Dai) = baseflow.Lxx;
            Lx(end)
            Fx(Rei,Dai) = baseflow.Fx;
            Fx(end)
            disp(' ')
            disp('***********  FIN ECRITURE  ***********')
            disp(' ')
            
            figure(1);
            %hold on
            semilogx(Darcyy,Lx(1,:),'.-');%,'.-',Darcy,Lx(2,:),'.-');
            xlabel('Da')
            ylabel('L_x')
            legend(['Re = ' num2str(Re(1))]);%,['Re = ' num2str(Re(2))],['Re = ' num2str(Re(3))],['Re = ' num2str(Re(4))])
            %hold off

            figure(2);
            %hold on
            semilogx(Darcyy,Fx(1,:),'.-');%,'.-',Darcy,Lx(2,:),'.-');
            xlabel('Da')
            ylabel('F_x')
            legend(['Re = ' num2str(Re(1))]);%,['Re = ' num2str(Re(2))],['Re = ' num2str(Re(3))],['Re = ' num2str(Re(4))])
            %hold off
            
        end
    end
end
save(['.\Resultats\Test_Lx_Fx\Re_' num2str(Re) '.mat'],'Darcyy','Lx','Fx')
toc;