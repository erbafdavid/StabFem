clear;
close all;
system('rm Gilgamesh.msh Heat_steady.ff2m Heat_unsteady.ff2m');  
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw -v 0'; %% Freefem command with full path
sfdir = '../SOURCES_MATLAB';
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts

addpath(sfdir);


[status] = system([ff ' freefem_example_Lshape.edp']);

if(status~=0) 
    disp('ERROR : FreeFem did not execute. Check path in line 3 of this script');

else
    disp('Freefem script was successfully ran');
    Gmesh=importFFmesh('Gilgamesh.msh');
    heatS = importFFdata(Gmesh,'Heat_steady.ff2m');
    heatU = importFFdata(Gmesh,'Heat_unsteady.ff2m');
    
    heatS.plottitle = 'Mesh';
    hand = plotFF(heatS,'mesh');

    heatS.plottitle = 'Solution of the steady heat equation on a L-shaped domain';
    hand = plotFF(heatS,'U');

    heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' heatU.omega ' : Re(Uc) ' ];
    heatU.xlim = [-.5,1.5]; 
    heatU.ylim = [-.5,1.5];
    hand = plotFF(heatU,'Uc',1);
    
    heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' heatU.omega ' : Im(Uc) ' ];
    hand = plotFF(heatU,'Uc',1i);
    
    heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' heatU.omega ' : |grad(Uc)| ' ];
    hand = plotFF(heatU,'normUc');
    
end
