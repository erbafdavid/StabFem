
% This mesh generator is for mesh "M2" of the JFM Longobardi et al.

function bf = SmartMesh_Hole(chi)

SF_Start;
verbosity=10;
close all;

bf = SF_Init('../Mesh_OneHole.edp',[chi,15,20,10,10]);
Params = [4 1e30 1. 0. 20 1e30]; % Lm, LA, LC, gammac, yA, yB
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
%bf = SF_BaseFlow(bf,'Re',1000);
bf = SF_Adapt(bf,'Hmax',0.5);
Params = [4 1e30 1.25 0.5 20 1e30];
bf = SF_SetMapping(bf,'mappingtype','jet','mappingparams',Params);
bf = SF_BaseFlow(bf,'Re',1000,'MappingParams', Params);
bf = SF_Adapt(bf,'Hmax',0.5);

bf = SF_BaseFlow(bf,'Re',1500,'MappingParams', Params);
bf = SF_Adapt(bf,'Hmax',.5);
%bf = SF_BaseFlow(bf,'Re',1500,'MappingParams', Params);
%bf = SF_Adapt(bf);


Omega1 = .5;
ForcedFlow1 = SF_LinearForced(bf,Omega1);
%figure; plotFF(ForcedFlow1,'ux1');
Omega2 = 4;
ForcedFlow2 = SF_LinearForced(bf,Omega2);
%figure; plotFF(ForcedFlow2,'ux1');
bf = SF_Adapt(bf,ForcedFlow1,ForcedFlow2,'Hmax',1);
 
end