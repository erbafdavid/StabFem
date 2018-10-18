function baseflow= SF_MeshGeneration(domain_parameters,ADAPTMODE)

%clear all
close all
global ffdataharmonicdir verbosity

disp_info=[' GENERATING  MESH :[' num2str(domain_parameters(1)) ':' num2str(domain_parameters(2)) ']x[0:' num2str(domain_parameters(3)) ']'];
disp(' ');  disp(disp_info); disp(' ');
verbosity=10;
baseflow=SF_Init('Mesh_Cylinder.edp', domain_parameters);
baseflow=SF_BaseFlow(baseflow,'Re',1);
baseflow=SF_BaseFlow(baseflow,'Re',10);
baseflow=SF_BaseFlow(baseflow,'Re',60);

%fig_mesh=plotFF(baseflow,'mesh'); %pause;
%set(fig_mesh, 'HandleVisibility', 'off'); %IMFT just have 3 licences, so...

disp(' ');disp('ADAPTING MESH FOR RE=60 ');disp(' ');

baseflow=SF_Adapt(baseflow,'Hmax',10,'InterpError',0.005);

%plotFF(baseflow,'mesh');%pause(0.1);
baseflow=SF_BaseFlow(baseflow,'Re',60);

disp(' ');disp('ADAPTING MESH FOR RE=60 ACORDING TO EIGENVALUE ');disp(' ');
%Mesh adaptation to a fluid mode
[ev,em] = SF_Stability(baseflow,'shift',0.04+0.74i,'nev',1,'type',ADAPTMODE);
[baseflow,em]=SF_Adapt(baseflow,em,'Hmax',1,'InterpError',0.02);

%[baseflow,em]=SF_Adapt(baseflow,em,'Hmax',10,'InterpError',0.005); fazia antes assim para o caso forcado
%plotFF(baseflow,'mesh');%pause(0.1);
%[baseflow,em]=SF_Adapt(baseflow,em,'Hmax',5,'InterpError',0.01);
%plotFF(baseflow,'mesh');%pause(0.1);
%[baseflow,em]=SF_Adapt(baseflow,em,'Hmax',5,'InterpError',0.01); 
%plotFF(baseflow,'mesh');%pause(0.1);
%baseflow=SF_Split(baseflow);
%plotFF(baseflow,'mesh');
%baseflow=SF_BaseFlow(baseflow,'Re',60);

end