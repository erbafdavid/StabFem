function [bf]= SmartMesh(type,mesh,varargin)
% THIS little functions generates and adapts a mesh for the wake of a cylinder.
% Adaptation type is either 'S' (mesh M2) or 'D' (mesh M4).

if(nargin==0)
    type='D';
    % parameters for mesh creation 
    % Outer Domain 
    mesh.xinfm=-40.; mesh.xinfv=80.; mesh.yinf=40.0
end

if(nargin==1)
    dimensions = [-40 80 40];
end

% varargin (optional input parameters)
p = inputParser;
addParameter(p, 'Ma', 0.3, @isnumeric); % variable
addParameter(p, 'Rec', 47.2, @isnumeric); % variable
addParameter(p, 'Omegac', 0.718, @isnumeric); % variable
addParameter(p, 'MeshRefine', 1.5, @isnumeric); % variable
Params =[mesh.xinfv*0.5 mesh.xinfm*0.5 10000000 mesh.xinfv*0.6 -0.0 mesh.yinf*0.5 10000000 mesh.yinf*0.6 -0.0] % x0, x1, LA, LC, gammac, y0, LAy, LCy, gammacy

parse(p, varargin{:});

Ma = p.Results.Ma;
Rec = p.Results.Rec;
Omegac = p.Results.Omegac;
meshRef = p.Results.MeshRefine;

% Inner domain
x1m=mesh.xinfm*0.0625; x1v=mesh.xinfv*0.125; y1=mesh.yinf*0.0625;
% Middle domain
x2m=mesh.xinfm*0.25;x2v=mesh.xinfv*0.4;y2=mesh.yinf*0.25;
% Sponge extension
ls=0.01; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=70; % Refinement density around the cylinder
n1=4; % Density in the inner domain
n2=2; % Density in the middle domain
ns=0.15; % Density in the outer domain
nsponge=.1; % density in the sponge region

MeshBased = type; % Used for mesh refinement
% Mesh generation
bf = SF_Init('Mesh.edp',[mesh.xinfm,mesh.xinfv,mesh.yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW','MappingParams',Params);
bf=SF_Adapt(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',meshRef);
if (MeshBased == 'S')
    bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
    [evD,emD] = SF_Stability(bf,'shift',0.11+0.704*1i,'nev',1,'type','S','sym','A','Ma',Ma);
    emD.filename='./WORK/Sensitivity.txt';
    emD.datastoragemode='ReP2';
    bf=SF_Adapt(bf,emD,'Hmax',meshRef);
else
   [evCr,emCr] = SF_Stability(bf,'shift',Omegac*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
   [evD,emD] = SF_Stability(bf,'shift',0.11+0.704*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_AdaptMesh(bf,emD,emCr,'Hmax',meshRef);
end

Params =[mesh.xinfv*0.5 mesh.xinfm*0.5 mesh.xinfv*1.84 mesh.xinfv*0.6 -0.3 mesh.yinf*0.5 mesh.yinf*1.84 mesh.yinf*0.6 -0.3] % x0, x1, LA, LC, gammac, y0, LAy, LCy, gammacy
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW','MappingParams',Params);


disp([' Adapted mesh has been generated ; number of vertices = ',num2str(bf.mesh.np)]);


end