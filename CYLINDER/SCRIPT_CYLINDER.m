% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  THIS SCRIPT DEMONSTRATES THE MESH CONVERGENCE USING ADAPTMESH 
%   TO BASEFLOW AND EIGENMODE.


global ff ffdir ffdatadir sfdir verbosity
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw -v 0'; %% Freefem command with full path 
ffdatadir = './DATA_FREEFEM_CYLINDER';
sfdir = '../SOURCES_MATLAB'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts
verbosity = 0;
addpath(sfdir);
system(['mkdir ' ffdatadir]);

disp(' ');
disp(' SMALL MESH : [-20:40]x[0:20] ');
disp(' ');

baseflow=FreeFem_Init('Mesh_Cylinder.edp');
baseflow=FreeFem_BaseFlow(baseflow,1);
baseflow=FreeFem_Adapt(baseflow,'Hmax',2);
baseflow=FreeFem_BaseFlow(baseflow,10);
baseflow=FreeFem_BaseFlow(baseflow,60);
baseflow=FreeFem_Adapt(baseflow,'Hmax',2);
[ev,em] = FreeFem_Stability(baseflow,'shift',0.04+0.76i,'nev',1);
disp('FIRST ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);
disp('2ND ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);
disp('3RD ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);
disp('4TH ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);

disp(' ');
disp(' LARGE MESH : [-40:120]x[0:40] ');
disp(' ');

baseflow=FreeFem_Init('Mesh_Cylinder_LARGE.edp');
baseflow=FreeFem_BaseFlow(baseflow,1);
baseflow=FreeFem_Adapt(baseflow,'Hmax',2);
baseflow=FreeFem_BaseFlow(baseflow,10);
baseflow=FreeFem_BaseFlow(baseflow,60);
baseflow=FreeFem_Adapt(baseflow,'Hmax',2);
[ev,em] = FreeFem_Stability(baseflow,'shift',0.04+0.76i,'nev',1);
disp('FIRST ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);
disp('2ND ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);
disp('3RD ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);
disp('4TH ADAPT TO MODE ')
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',2);





 