function [bf]= smartmesh(varargin)
%  function SmartMesh
%  Generate a mesh for the BirdCall case
%  Usage :
%  1/ bf= smartmesh('Ma',0.05,'MeshRefine',1,'RefineType','S')
%      to generate a mesh for a given Mach and based on a technique to
%      adapt the mesh ('D','S','BF')
%
%  Results are stored in bf
%


%% Parameters
% varargin (optional input parameters)
p = inputParser;
addParameter(p, 'Ma', 0.05, @isnumeric); % variable
addParameter(p, 'MeshRefine', 1.0, @isnumeric); % variable
addParameter(p, 'RefineType', 'D', @ischar); % variable

parse(p, varargin{:});

Ma = p.Results.Ma;
meshRef = p.Results.MeshRefine;
RefineType = p.Results.RefineType;

%% No Complex Mapping nor stretching
LA = 10000;
Params =[10000 10000 LA 10000 0.0 10000 LA 10000 0.0]

%% Begin mesh generation
bf = SF_Init('Mesh_BirdCall.edp');
bf.mesh = SF_SetMapping(bf.mesh,'mappingtype','box','mappingparams',Params); 
bf=SF_BaseFlow(bf,'Re',1,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',30,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',200,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',320,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',640,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',960,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
if(RefineType == 'D')
    [ev1,em1] = SF_Stability(bf,'shift',0.35-3.3i,'m',0,'nev',1,'type','D');
    em1.filename='./WORK/Eigenmode1.txt';
    mycp('./WORK/Eigenmode.txt','./WORK/Eigenmode1.txt');
    
    [ev2,em2] = SF_Stability(bf,'shift',0.95-5.2i,'m',0,'nev',1,'type','D');
    em2.filename='./WORK/Eigenmode2.txt';
    mycp('./WORK/Eigenmode.txt','./WORK/Eigenmode2.txt');
    bf=SF_Adapt(bf,em1,em3,'Hmax',meshRef); %For 30x30
elseif(RefineType == 'S')
    [ev1,em1] = SF_Stability(bf,'shift',0.35-3.3i,'m',0,'nev',1,'type','S');
    em1.filename='./WORK/Sensitivity1.txt';
    mycp('./WORK/Sensitivity.txt','./WORK/Sensitivity1.txt');
    em1.datastoragemode='ReP2';
    
    [ev2,em2] = SF_Stability(bf,'shift',0.95-5.2i,'m',0,'nev',1,'type','S');
    em2.filename='./WORK/Sensitivity2.txt';
    mycp('./WORK/Sensitivity.txt','./WORK/Sensitivity2.txt');
    em2.datastoragemode='ReP2';
	bf=SF_Adapt(bf,em1,em2,'Hmax',meshRef);
else
    bf=SF_Adapt(bf,'Hmax',meshRef);
end
bf=SF_BaseFlow(bf,'Re',1280,'Mach',Ma,'ncores',1,'type','NEW');

if(RefineType == 'D')
    [ev1,em1] = SF_Stability(bf,'shift',0.4-3.3i,'m',0,'nev',1,'type','D');
    em1.filename='./WORK/Eigenmode1.txt';
    mycp('./WORK/Eigenmode.txt','./WORK/Eigenmode1.txt');
    
	[ev4,em4] = SF_Stability(bf,'shift',0.45-9.2i,'m',0,'nev',1,'type','D');
    em4.filename='./WORK/Eigenmode4.txt';
    mycp('./WORK/Eigenmode.txt','./WORK/Eigenmode4.txt');
    bf=SF_Adapt(bf,em1,em4,'Hmax',meshRef);
elseif(RefineType == 'S')
    [ev1,em1] = SF_Stability(bf,'shift',0.35-3.3i,'m',0,'nev',1,'type','S');
    em1.filename='./WORK/Sensitivity1.txt';
    mycp('./WORK/Sensitivity.txt','./WORK/Sensitivity1.txt');
    em1.datastoragemode='ReP2';

    [ev4,em4] = SF_Stability(bf,'shift',0.45-9.2i,'m',0,'nev',1,'type','S');
    em4.filename='./WORK/Sensitivity4.txt';
    mycp('./WORK/Sensitivity.txt','./WORK/Sensitivity4.txt');
    em4.datastoragemode='ReP2';
    bf=SF_Adapt(bf,em1,em4,'Hmax',meshRef);
else
    bf=SF_Adapt(bf,'Hmax',meshRef);
end

bf=SF_BaseFlow(bf,'Re',1600,'Mach',Ma,'ncores',1,'type','NEW');

end