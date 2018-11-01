
function bf = SmartMesh_Hole_NoMap
SF_Start;

verbosity=10;
close all;

chi = 1;
bf = SF_Init('Mesh_OneHole.edp',[chi,15,60,10,10]);

bf = SF_BaseFlow(bf,'Re',1);
bf = SF_BaseFlow(bf,'Re',10);
bf = SF_BaseFlow(bf,'Re',30 );
bf = SF_BaseFlow(bf,'Re',100 );
%SF_Status('BASEFLOWS')
bf = SF_Adapt(bf,'Hmax',1); 
%SF_Status('BASEFLOWS')
bf = SF_BaseFlow(bf,'Re',300 );
bf = SF_Adapt(bf,'Hmax',1);
bf = SF_BaseFlow(bf,'Re',600 );
bf = SF_Adapt(bf,'Hmax',1);
bf = SF_BaseFlow(bf,'Re',1000 );
bf = SF_Adapt(bf,'Hmax',1);
bf = SF_BaseFlow(bf,'Re',1500 );
bf = SF_Adapt(bf,'Hmax',1);


[ev,em]=SF_Stability(bf,'nev',1,'type','A','m',0,'shift', -2.06i)
bf=SF_Adapt(bf,em,'Hmax',1)

bf = SF_BaseFlow(bf,'Re',2000 );
%[ev,em] = SF_Stability(bf,'nev',10,'type','A','m',0,'shift', 3i+2,'plotspectrum','yes')
[ev1,em1]=SF_Stability(bf,'nev',1,'type','A','m',0,'shift', 0.3+2.23i)
[ev2,em2]=SF_Stability(bf,'nev',1,'type','A','m',0,'shift', 0.22+4.33i)

bf=SF_Adapt(bf,em1,em2,'Hmax',1)

end