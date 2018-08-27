function [bf]= SmartMesh(type,mesh,varargin)
% THIS little functions generates and adapts a mesh for the wake of a cylinder.
% Adaptation type is either 'S' (mesh M2) or 'D' (mesh M4).

if(nargin==0)
    type='D';
    % parameters for mesh creation 
    % Outer Domain 
    mesh.xinfm=-40.; mesh.xinfv=100.; mesh.yinf=40.0
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

parse(p, varargin{:});

Ma = p.Results.Ma;
Rec = p.Results.Rec;
Omegac = p.Results.Omegac;
meshRef = p.Results.MeshRefine;

% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=30.;y2=10;
% Sponge extension
ls=0.01; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=70; % Refinement density around the cylinder
n1=4; % Density in the inner domain
n2=2; % Density in the middle domain
ns=0.15; % Density in the outer domain
nsponge=.1; % density in the sponge region
% parameters for mesh creation 
% This parameter is used if sponge is selected
method.alpha = 0.0;
% Either Complex mapping (CM) or Sponge (S)
method.name = 'CM';
% symmetric (1) or full domain (2)
method.symm = 2;
% 0 indicates antisymmetry for the mode, 1 symmetry, 2 full domain
method.symmEig = 2;

CM.BoxXpCoeff = 1.2;
CM.BoxXnCoeff = -1.3;
CM.BoxYpCoeff = 1.15;
CM.LaXpCoeff = 1.01;
CM.LaXnCoeff = 1.01;
CM.LaYpCoeff = 1.01;
CM.LcXpCoeff = 0.4;
CM.LcXnCoeff = 0.5;
CM.LcYpCoeff = 0.35;
CM.gcXpCoeff = 0.0;
CM.gcXnCoeff = 1.0;
CM.gcYpCoeff = 0.0;

myWriteMethod(CM,mesh,method);

MeshBased = type; % Used for mesh refinement
% Mesh generation
bf = SF_Init('Mesh.edp',[mesh.xinfm,mesh.xinfv,mesh.yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',meshRef);
if (MeshBased == 'S')
    bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
    [evD,emD] = SF_Stability(bf,'shift',Omegac*i,'nev',1,'type','S','sym','A','Ma',Ma);
    emD.filename='./WORK/Sensitivity.txt';
    emD.datastoragemode='ReP2';
    bf=SF_AdaptMesh(bf,emD,'Hmax',meshRef);
    bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
    [evD,emD] = SF_Stability(bf,'shift',0.042534+0.73094i,'nev',1,'type','S','sym','A','Ma',Ma);
    emD.filename='./WORK/Sensitivity.txt';
    emD.datastoragemode='ReP2';
    bf=SF_AdaptMesh(bf,emD,'Hmax',meshRef);
    [evD,emD] = SF_Stability(bf,'shift',0.042534+0.73094i,'nev',1,'type','D','sym','A','Ma',Ma);
else
   [evCr,emCr] = SF_Stability(bf,'shift',Omegac*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
   [evD,emD] = SF_Stability(bf,'shift',0.11+0.685*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_AdaptMesh(bf,emD,emCr,'Hmax',meshRef);
end

disp([' Adapted mesh has been generated ; number of vertices = ',num2str(bf.mesh.np)]);


end