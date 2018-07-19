function bf = SmartMesh_Porous_Rotating_Disk();

%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%                          -- MESH --
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%                                                   
%#####################################################################


%% 0 - Préchauffage

run('../../SOURCES_MATLAB/SF_Start.m');
addpath(sfdir);

ff = 'FreeFem++ -nw -v 0';
ffdatadir = 'WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational
figureformat = 'png';

verbosity = 0;

%% 1 - Génération MAILLAGE et BASEFLOW

Rx = 3;

% Géométrie
Diametre = 1;
Rayon = Diametre/2;
Epaisseur = 1/(2*Rx);
Xmin = -20*Rayon;
Xmax = 100*Rayon;
Ymax = 20*Rayon;

bf = SF_Init('mesh_Disk.edp',[Diametre Epaisseur Xmin Xmax Ymax]);

% Paramètres de calcul
Omega = 0.;
Darcy = 1e-6;
Porosite = 0.95;

% Baseflow Re=150
bf = SF_BaseFlow(bf,'Re',10,'Omegax',Omega,'Darcy',Darcy,'Porosity',Porosite);
bf = SF_BaseFlow(bf,'Re',50);
bf = SF_BaseFlow(bf,'Re',70);
bf = SF_Adapt(bf,'Hmin',1e-5,'Hmax',5);
bf = SF_BaseFlow(bf,'Re',80);
bf = SF_BaseFlow(bf,'Re',100);
bf = SF_BaseFlow(bf,'Re',130);bf = SF_Adapt(bf,'Hmin',1e-5,'Hmax',5);
bf = SF_BaseFlow(bf,'Re',150);
bf = SF_Adapt(bf,'Hmin',1e-5,'Hmax',5);
bf = SF_Adapt(bf,'Hmin',1e-5,'Hmax',5);

%% 3 - Spectrum exploration #1 

% first exploration for m=1

m = 1;

EV = [0.0084-0.7142i 0.0478 0.0084+0.7142i];
type = 'S' % essayer S ou D
[EV(1),em] = SF_Stability(bf,'m',m,'shift',EV(1),'nev',1,'type',type);

bf = SF_Adapt(bf,em,'Hmin',1e-5,'Hmax',5);


end