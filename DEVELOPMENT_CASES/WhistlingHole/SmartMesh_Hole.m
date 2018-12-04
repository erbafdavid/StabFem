% This function is for mesh "M1" of the JFM by Longobardi et al.

function bf = SmartMesh_Hole(chi)
% Warning gammac is negative here !

SF_Start;
verbosity=10;
close all;

bf = SF_Init('Mesh_OneHole.edp',[chi,15,15,10,10]);
Params = [0 17 2.5 0.3 5 17]; % Lm, LA, LC, gammac, yA, yB
bf.mesh = SF_SetMapping(bf.mesh,'mappingtype','jet','mappingparams',Params);

bf = SF_BaseFlow(bf,'Re',1);
bf = SF_BaseFlow(bf,'Re',10);
bf = SF_Adapt(bf,'Hmax',0.5);
bf = SF_BaseFlow(bf,'Re',30);
bf = SF_BaseFlow(bf,'Re',100);
bf = SF_Adapt(bf,'Hmax',0.5); 
Params = [0 17 2.5 0.1 5 17];
bf = SF_SetMapping(bf,'mappingtype','jet','mappingparams',Params);
bf = SF_BaseFlow(bf,'Re',300);
bf = SF_Adapt(bf,'Hmax',0.5);
Params = [0 17 2.5 0.3 5 17];
bf = SF_SetMapping(bf,'mappingtype','jet','mappingparams',Params);
bf = SF_BaseFlow(bf,'Re',1000);
bf = SF_Adapt(bf,'Hmax',0.5);
bf = SF_BaseFlow(bf,'Re',1500);
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