
function bf = SmartMesh_Hole_MeshM2
% Mesh M2 of the paper

chi = 1;
SF_Start;
verbosity=10;
close all;

bf = SF_Init('Mesh_OneHole.edp',[1,15,20,10,10]);
Params = [4 1e30  1 0. 20 1e30]; % Lm, LA, LC, gammac, yA, yB
bf.mesh = SF_SetMapping(bf.mesh,'mappingtype','jet','mappingparams',Params);

bf = SF_BaseFlow(bf,'Re',1);
bf = SF_Adapt(bf,'Hmax',0.5); 
bf = SF_BaseFlow(bf,'Re',30);
bf = SF_BaseFlow(bf,'Re',100);
bf = SF_Adapt(bf,'Hmax',0.5); 
bf = SF_BaseFlow(bf,'Re',300);
bf = SF_BaseFlow(bf,'Re',1000);
bf = SF_Adapt(bf,'Hmax',0.5);

Params = [4 1e30 1. 0.2 20 1e30];
bf = SF_SetMapping(bf,'mappingtype','jet','mappingparams',Params);
bf = SF_Adapt(bf,'Hmax',0.5);

Params = [4 1e30 1.25 0.5 20 1e30];
bf = SF_SetMapping(bf,'mappingtype','jet','mappingparams',Params);
bf = SF_Adapt(bf,'Hmax',0.5);

bf = SF_BaseFlow(bf,'Re',1500,'MappingParams', Params);
bf = SF_Adapt(bf,'Hmax',.5);


Omega1 = .5;
ForcedFlow1 = SF_LinearForced(bf,Omega1);
Omega2 = 2.1;
ForcedFlow2 = SF_LinearForced(bf,Omega2);
Omega3 = 4.5;
ForcedFlow3 = SF_LinearForced(bf,Omega3);

bf = SF_Adapt(bf,ForcedFlow1,ForcedFlow2,ForcedFlow3,'Hmax',.25);
 
end