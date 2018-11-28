%  Instability of the wake of a cylinder with STABFEM  
%
%  THIS SCRIPT COMPARES THE RESULTS OBTAINED WITH 7 DIFFERENT MESHES

% CHAPTER 0 : set the global variables needed by the drivers

run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=0;
figureformat='png'; AspectRatio = 0.56; % for figure

 
%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 1 : MESH based on base flow : ');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder.edp',[-40 80 40]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);
 
disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 2 : ADAPT ON SENSITIVITY (ref case)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);


% plot the mesh (full size)
bf.xlim = [-40 80]; bf.ylim=[0,40];
SF_Plot(bf,'mesh');
%title('Mesh M2 (full size)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.4;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'FIGURES/Cylinder_Mesh2_Full',figureformat); 

% plot the mesh (zoom)
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
SF_Plot(bf,'mesh');
%title('Mesh M2 (zoom)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'FIGURES/Cylinder_Mesh2',figureformat);
pause(0.1);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 2bis : ADAPT ON SENSITIVITY (split)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bf=SF_Split(bf);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');

disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 3 : ADAPT ON ENDOGENEITY');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','E');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','E');
bf=SF_Adapt(bf,em,'Hmax',10);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);
[meanflow,mode] = SF_HB1(bf,em,'sigma',0.04,'Re',60,'FYguess',0.015);
%[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);





%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 4 : ADAPT ON MODE');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
bf=SF_Adapt(bf,em,'Hmax',10);

% plot the mesh (full size)
bf.xlim = [-40 80]; bf.ylim=[0,40];
SF_Plot(bf,'mesh');
%title('Mesh M4 (full size)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.4;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'FIGURES/Cylinder_Mesh4_Full',figureformat); 

% plot the mesh (zoom)
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
SF_Plot(bf,'mesh');
%title('Mesh M4 (zoom)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'FIGURES/Cylinder_Mesh4',figureformat);
pause(0.1);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D','nev',1);
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);





%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 5 : ADAPT ON MODE (adjoint)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%bf=SF_Split(bf);
bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','A');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','A');
bf=SF_Adapt(bf,em,'Hmax',10);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);







%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 6 : [-20 40 20]');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder.edp',[-20 40 20]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);



disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);


%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 7 : [-80 160 80]');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder.edp',[-80 160 80]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);





%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 8 : [-40 80 40] WITH SLIP CONDITIONS');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder_SlipConditions.edp',[-40 80 40]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);

%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 9 : [-40 80 40] WITH NO SLIP CONDITIONS');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder_NoSlipConditions.edp',[-40 80 40]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
bf=SF_Adapt(bf,em,'Hmax',10);

disp(' ');
disp(['number of vertices : ' num2str(bf.mesh.np)]);
disp(['number of DOF : ' num2str(bf.mesh.Ndof)]);
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.74i,'type','D');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_HB1(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_HB1(meanflow,mode,'Re',60,'sigma',0.0,'specialmode','NEW');

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);

