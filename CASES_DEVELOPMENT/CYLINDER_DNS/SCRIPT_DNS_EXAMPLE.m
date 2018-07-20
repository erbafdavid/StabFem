% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  THIS SCRIPT DEMONSTRATES HOW TO DO DNS with StabFem

run('../../SOURCES_MATLAB/SF_Start.m');verbosity = 10;
figureformat='png'; AspectRatio = 0.56; % for figures


%% Chapter 1 : generation of a mesh and base flow for Re=60
type = 'S';
bf = SF_Init('Mesh_Cylinder_FullDomain.edp');
bf=SF_BaseFlow(bf,'Re',1);
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_Adapt(bf,'Hmax',5);
disp(' ');
disp(['mesh adaptation  : type ',type])
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type',type);
bf=SF_Adapt(bf,em,'Hmax',5);
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type',type);
bf=SF_Adapt(bf,em,'Hmax',5);
disp([' Adapted mesh has been generated ; number of vertices = ',num2str(bf.mesh.np)]);

%% Chapter 2 : how to do a DNS starting from the base flow
%  We do 1000 time steps and produce output each 100 timestep 


[DNSstats,DNSfields] = SF_DNS(bf,'Re',60,'Nit',1000,'dt',0.005,'iout',100)


%% Chapter 3 : how to do a DNS starting from a previous snapshot
%  We do another 1000 time steps starting from previous point 

DNSfield = DNSfields(end);
[DNSstats,DNSfields] = SF_DNS(DNSfield,'Re',60,'Nit',20,'dt',0.005,'iout',100)

