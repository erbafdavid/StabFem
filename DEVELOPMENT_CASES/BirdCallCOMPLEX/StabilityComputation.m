run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;
Ma = 0.05;

if(exist('bf','var'))
    ffmesh = importFFmesh('./WORK/MESHES/mesh_adapt11_Re1600_Ma0.05.msh');
    bf = importFFdata(ffmesh,'./WORK/MESHES/BaseFlow_adapt11_Re1600_Ma0.05.ff2m');
else
    bf = smartmesh('Ma',0.05,'MeshRefine',1,'RefineType','S');
end

%% COMPLEX MAPPING COMPUTATION OF THE 4 BRANCHES
LA = 10000;
LAy = 10000;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',1600,'Mach',Ma,'ncores',1,'type','NEW');
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
%Params =[30 30 LA 20.0 0.15 30.0 LAy 20.0 0.15]
bf=SF_BaseFlow(bf,'Re',1600,'Mach',Ma,'ncores',1,'type','NEW');


em1BranchListH = [];
em2BranchListH = [];
em3BranchListH = [];
em4BranchListH = [];
ev1BranchListH = [];
ev2BranchListH = [];
ev3BranchListH = [];
ev4BranchListH = [];
ev1BranchListH = [ev1BranchListH, ev1];
ev2BranchListH = [ev2BranchListH, ev2];
em1BranchListH = [em1BranchListH, em1];
em2BranchListH = [em2BranchListH, em2];
ev3BranchListH = [ev3BranchListH, ev3];
em3BranchListH = [em3BranchListH, em3];
ev4BranchListH = [ev4BranchListH, ev4];
em4BranchListH = [em4BranchListH, em4];

ev1Guess = ev1;
ev2Guess = ev2;
ev3Guess = ev3;
ev4Guess = ev4;
Re_RangeHigh = [1520:-80:320];

for Re=Re_RangeHigh
    bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW','MappingParams',Params);
    [ev1,em1] = SF_Stability(bf,'shift',ev1Guess,'m',0,'nev',1,'type','D')
    [ev2,em2] = SF_Stability(bf,'shift',ev2Guess,'m',0,'nev',1,'type','D')
    ev1BranchListH = [ev1BranchListH, ev1];
    ev2BranchListH = [ev2BranchListH, ev2];
    em1BranchListH = [em1BranchListH, em1];
    em2BranchListH = [em2BranchListH, em2];
    
    if(Re >= 640)
        [ev3,em3] = SF_Stability(bf,'shift',ev3Guess,'m',0,'nev',1,'type','D')
        ev3BranchListH = [ev3BranchListH, ev3];
        em3BranchListH = [em3BranchListH, em3];
        ev3Guess = 2*ev3 - ev3Guess;
    end
    
     if(Re >= 1200)
        [ev4,em4] = SF_Stability(bf,'shift',ev4Guess,'m',0,'nev',1,'type','D')
        ev4BranchListH = [ev4BranchListH, ev4];
        em4BranchListH = [em4BranchListH, em4];
        ev4Guess = 2*ev4 - ev4Guess;
     end
         
    ev1Guess = 2*ev1 - ev1Guess;
    ev2Guess = 2*ev2 - ev2Guess;
end


%% Generation of plots
y0 = linspace(0,2,20)
x0 = -1.0*ones(1,20)
SF_Plot(bf,'ux','Streamlines','yes','Streamlinesx0',x0,'StreamlinesY0',y0)

