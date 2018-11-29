run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;
Ma = 0.05;

% Set your files here (Mesh generation)
directory = '../BirdCallComplex/MESH30x30DIRECT/';
baseFlowFile = [directory,'MESHES/BaseFlow_adapt10_Re1280_Ma0.05.ff2m'];
meshFile = [directory,'MESHES/mesh_adapt10_Re1280_Ma0.05.msh'];

% Check whether the baseflow exists or the mesh shall be created
if(exist(baseFlowFile,'file') == 2 && exist(meshFile,'file') == 2)
    ffmesh = importFFmesh(meshFile);
    bf = importFFdata(ffmesh,baseFlowFile);
else
    bf = smartmesh('Ma',0.05,'MeshRefine',1,'RefineType','S');
end

%  Compute base flow at Re = 1600
bf=SF_BaseFlow(bf,'Re',1600,'Mach',Ma,'ncores',1,'type','NEW');

% Do the complex mapping
LA = 10000;
LAy = 10000;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1] % x0, x1, LA, Lc, gc, y0, LAy, Lcy, gcy
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);

% Arrays to store sensitivity and adjoint fields
emStore = [];
evStore = [];

emAdj = [];
evAdj = [];

type = 'S';

% Compute Sensitivity at Re = 1600
bf=SF_BaseFlow(bf,'Re',1600,'Mach',Ma,'ncores',1,'type','NEW');
bf1600 = bf;
[ev1,em1] = SF_Stability(bf,'shift',0.45-3.3i,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',0.95-5.2i,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',0.9-7.2i,'m',0,'nev',1,'type',type);
[ev4,em4] = SF_Stability(bf,'shift',0.45-9.2i,'m',0,'nev',1,'type',type);

emStore = [em1,em2,em3,em4];
evStore = [ev1,ev2,ev3,ev4];

% Compute Sensitivity at Re = 1200
bf=SF_BaseFlow(bf,'Re',1200,'Mach',Ma,'ncores',1,'type','NEW');
bf1200 = bf;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',ev3,'m',0,'nev',1,'type',type);
[ev4,em4] = SF_Stability(bf,'shift',ev4,'m',0,'nev',1,'type',type);

emStore = [emStore; em1,em2,em3,em4];
evStore = [evStore; ev1,ev2,ev3,ev4];

% Compute Sensitivity at Re = 960
bf=SF_BaseFlow(bf,'Re',960,'Mach',Ma,'ncores',1,'type','NEW');
bf960 = bf;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',ev3,'m',0,'nev',1,'type',type);

emStore = [emStore; em1,em2,em3,em3];
evStore = [evStore; ev1,ev2,ev3,0];

% Compute Sensitivity at Re = 640
bf640 = bf;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',ev3,'m',0,'nev',1,'type',type);

emStore = [emStore; em1,em2,em3,em3];
evStore = [evStore; ev1,ev2,ev3,0];

% Compute Sensitivity at Re = 320
bf320 = bf;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);

emStore = [emStore; em1,em2,em2,em2];
evStore = [evStore; ev1,ev2,0,0];


%% Compute Adjoint

type = 'A';
% Compute Sensitivity at Re = 1600
bf = bf1600;
[ev1,em1] = SF_Stability(bf,'shift',0.45-3.3i,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',0.95-5.2i,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',0.9-7.2i,'m',0,'nev',1,'type',type);
[ev4,em4] = SF_Stability(bf,'shift',0.45-9.2i,'m',0,'nev',1,'type',type);

emAdj = [em1,em2,em3,em4];
evAdj = [ev1,ev2,ev3,ev4];

% Compute Sensitivity at Re = 1200
bf = bf1200;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',ev3,'m',0,'nev',1,'type',type);
[ev4,em4] = SF_Stability(bf,'shift',ev4,'m',0,'nev',1,'type',type);

emAdj = [emStore; em1,em2,em3,em4];
evAdj = [evStore; ev1,ev2,ev3,ev4];

% Compute Sensitivity at Re = 960
bf = bf960;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',ev3,'m',0,'nev',1,'type',type);

emAdj = [emStore; em1,em2,em3,em3];
evAdj = [evStore; ev1,ev2,ev3,0];

% Compute Sensitivity at Re = 640
bf = bf640;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);
[ev3,em3] = SF_Stability(bf,'shift',ev3,'m',0,'nev',1,'type',type);

emAdj = [emStore; em1,em2,em3,em3];
evAdj = [evStore; ev1,ev2,ev3,0];

% Compute Sensitivity at Re = 320
bf = bf320;
[ev1,em1] = SF_Stability(bf,'shift',ev1,'m',0,'nev',1,'type',type);
[ev2,em2] = SF_Stability(bf,'shift',ev2,'m',0,'nev',1,'type',type);

emAdj = [emStore; em1,em2,em2,em2];
evAdj = [evStore; ev1,ev2,0,0];

