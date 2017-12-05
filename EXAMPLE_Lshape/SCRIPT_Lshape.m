
run('../SOURCES_MATLAB/SF_Start.m');

% importation of a mesh and data field 'base flow' 
heatS=SF_Init('freefem_example_Lshape.edp')

% plot the mesh and the associated data
heatS.plottitle = 'Mesh';
hand = plotFF(heatS,'mesh');

heatS.plottitle = 'Solution of the steady heat equation on a L-shaped domain';
hand = plotFF(heatS,'T');

heatU=importFFdata(baseflow.mesh,'Heat_unsteady.ff2m');    

heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' heatU.omega ' : Re(Uc) ' ];
heatU.xlim = [-.5,1.5]; 
heatU.ylim = [-.5,1.5];
hand = plotFF(heatU,'Tc.re');
    
heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' heatU.omega ' : Im(Uc) ' ];
hand = plotFF(heatU,'Tc.im');
    
heatU.plottitle = ['Solution of the unsteady heat equation for omega = ' heatU.omega ' : |grad(Uc)| ' ];
hand = plotFF(heatU,'normTc');
    

