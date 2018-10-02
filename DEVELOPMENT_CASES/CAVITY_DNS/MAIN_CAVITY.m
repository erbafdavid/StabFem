clear all;
close all;
run('../../SOURCES_MATLAB/SF_Start.m');
   
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');
disp(' ');    
verbosity=100;
bf=SF_Init('Mesh_Cavity.edp'); %Do it with input parameters

bf=SF_BaseFlow(bf,'Re',500);
bf=SF_BaseFlow(bf,'Re',1000);
bf=SF_BaseFlow(bf,'Re',1500);
bf=SF_BaseFlow(bf,'Re',3000);
bf=SF_BaseFlow(bf,'Re',4140);

bf=SF_Adapt(bf,'Hmax',0.1);
bf=SF_BaseFlow(bf,'Re',4140); % not needed, I think
disp(' '); disp('mesh adaptation to SENSIBILITY : ')
[ev,em] = SF_Stability(bf,'shift',0.0+7.5i,'nev',1,'type','S');
[bf,em]=SF_Adapt(bf,em,'Hmax',0.1);

%% Chapter 2 : how to do a DNS starting from the base flow
%  We do 1000 time steps and produce output each 100 timestep 

Re  = 5000;

[DNSstats,DNSfields] = SF_DNS(bf,'Re',Re,'Nit',20000,'dt',2e-4,'iout',200)


%% Chapter 3 : how to do a DNS starting from a previous snapshot
%  We do another 1000 time steps starting from previous point 

%DNSfield = DNSfields(end);
%[DNSstats,DNSfields] = SF_DNS(DNSfield,'Re',Re,'Nit',20,'dt',,'iout',100)



