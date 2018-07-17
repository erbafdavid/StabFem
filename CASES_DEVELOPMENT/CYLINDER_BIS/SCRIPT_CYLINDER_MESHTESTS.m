%  Instability of the wake of a cylinder with STABFEM  
%
%  THIS SCRIPT COMPARES THE RESULTS OBTAINED WITH 7 DIFFERENT MESHES

% CHAPTER 0 : set the global variables needed by the drivers

run('../SOURCES_MATLAB/SF_Start.m');
verbosity=0;
figureformat='png'; AspectRatio = 0.56; % for figure

 
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
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);



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
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ' );
% disp('### 3 : ADAPT ON SENSITIVITY (Hmax = 1)');
% disp(' ' );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% bf=SF_BaseFlow(bf,'Re',60);
% [ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
% bf=SF_Adapt(bf,em,'Hmax',1);
% [ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','S');
% bf=SF_Adapt(bf,em,'Hmax',1);
% 
% disp(' ');
% disp(['number of vertices : ' num2str(bf.mesh.np)]);
% disp('### Mesh grid size at point A,B,C,D : ');
% disp(['A   : ' num2str(bf.mesh.deltaA)]);
% disp(['B   : ' num2str(bf.mesh.deltaB)]);
% disp(['C   : ' num2str(bf.mesh.deltaC)]);
% disp(['D   : ' num2str(bf.mesh.deltaD)]);
% disp(['min : ' num2str(bf.mesh.deltamin)]);
% disp(['max : ' num2str(bf.mesh.deltamax)]);
% disp(' ' );
% 
% bf=SF_BaseFlow(bf,'Re',60);
% [ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
% disp('##### EIGENVALUE COMPUTATION');
% 
% disp([' Eigenvalue : ' , num2str(ev)]);
% 
% [meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
% [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
% [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
% [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);
% 
% disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
% disp(['mean Fx : ' num2str(meanflow.Fx)]);
% disp(['mean Lx : ' num2str(meanflow.Lx)]);
% disp(['Mode Fy : ' num2str(mode.Fy)]);
% disp(['Mode AE : ' num2str(mode.AEnergy)]);
% disp(['Mode omega : ' num2str(imag(mode.lambda))]);
% 
% 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 3 : ADAPT ON SENSITIVITY (split)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bf=SF_Split(bf);

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
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');

disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 5 : ADAPT ON MODE');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
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
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 6 : ADAPT ON MODE (split)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bf=SF_Split(bf);

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
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');

disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 7 : ADAPT ON MODE (adjoint)');
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
disp('### Mesh grid size at point A,B,C,D : ');
disp(['A   : ' num2str(bf.mesh.deltaA)]);
disp(['B   : ' num2str(bf.mesh.deltaB)]);
disp(['C   : ' num2str(bf.mesh.deltaC)]);
disp(['D   : ' num2str(bf.mesh.deltaD)]);
disp(['min : ' num2str(bf.mesh.deltamin)]);
disp(['max : ' num2str(bf.mesh.deltamax)]);
disp(' ' );

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);








 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 11 : [-20 40 20]');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder.edp',[-20 40 20]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
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
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);



 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 12 : [-80 160 80]');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder.edp',[-80 160 80]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
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
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);






 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(' ');    
 disp('### 13 : [-40 80 40] WITH SLIP CONDITIONS');     
 disp(' ');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 bf=SF_Init('Mesh_Cylinder_SlipConditions.edp',[-40 80 40]);
 bf=SF_BaseFlow(bf,'Re',1);
 bf=SF_BaseFlow(bf,'Re',10);
 bf=SF_BaseFlow(bf,'Re',60);
 bf=SF_Adapt(bf,'Hmax',10);
 bf=SF_Adapt(bf,'Hmax',10);

bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+.745i,'type','D');
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
[ev,em] = SF_Stability(bf,'shift',0.47+.74i,'type','S');
disp('##### EIGENVALUE COMPUTATION');

disp([' Eigenvalue : ' , num2str(ev)]);

[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'Re',60,'sigma',0.04,'Fyguess',0.015);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.03);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.02);
[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',60,'sigma',0.0);

disp('##### NONLINEAR SELFCONSISTENT COMPUTATION');
disp(['mean Fx : ' num2str(meanflow.Fx)]);
disp(['mean Lx : ' num2str(meanflow.Lx)]);
disp(['Mode Fy : ' num2str(mode.Fy)]);
disp(['Mode AE : ' num2str(mode.AEnergy)]);
disp(['Mode omega : ' num2str(imag(mode.lambda))]);







% Re_Range = [40 : 5: 100];
% Drag_tab = []; Lx_tab = [];lambda_branch=[];
%     for Re = Re_Range
%         bf = SF_BaseFlow(bf,'Re',Re);
%         Drag_tab = [Drag_tab,bf.Cx];
%         Lx_tab = [Lx_tab,bf.Lx];
%         [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
%         lambda_branch = [lambda_branch ev];
%     end    
% figure(80);    
% plot(Re_Range,real(lambda_branch));
% hold on;
% figure(81);
% plot(Re_Range,imag(lambda_branch));
% hold on;
% pause(0.1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ' );
% disp('### 3 : ADAPT ON MODE');
% disp(' ' );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% bf=SF_BaseFlow(bf,'Re',60);
% [ev,em] = SF_Stability(bf,'shift',.04+.72i,'type','D');
% bf=SF_Adapt(bf,em,'Hmax',10);
% [ev,em] = SF_Stability(bf,'shift','prev','type','D');
% 
% disp(' ');
% disp('### Mesh grid size at point A,B,C,D : ');
% disp(['A : ' num2str(bf.mesh.deltaA)]);
% disp(['B : ' num2str(bf.mesh.deltaB)]);
% disp(['C : ' num2str(bf.mesh.deltaC)]);
% disp(['D : ' num2str(bf.mesh.deltaD)]);
% disp(' ' );
% 
% 
% % create figure for this mode;
% em.xlim = [-2 8]; em.ylim=[0,5];
% plotFF(em,'ux1');
% title('Eigenmode at Re=60');
% box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.56;set(gcf,'Position',pos); % resize aspect ratio
% set(gca,'FontSize', 18);
% saveas(gca,'Cylinder_EigenModeRe60',figureformat);
% 
% % loop
% Re_Range = [40 : 5: 100];
% bf=SF_BaseFlow(bf,'Re',40);
% [ev,em] = SF_Stability(bf,'shift',-0.03+.72i,'type','S');
% Drag_tab = []; Lx_tab = [];lambda_branch=[];
%     for Re = Re_Range
%         bf = SF_BaseFlow(bf,'Re',Re);
%         Drag_tab = [Drag_tab,bf.Cx];
%         Lx_tab = [Lx_tab,bf.Lx];
%         [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
%         lambda_branch = [lambda_branch ev];
%     end
% figure(80);    
% plot(Re_Range,real(lambda_branch));
% hold on;
% figure(81);
% plot(Re_Range,imag(lambda_branch));
% hold on;
% pause(0.1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ' );
% disp('### 4 : ADAPT ON SENSITIVITY (err = 0.005)');
% disp(' ' );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% bf=SF_BaseFlow(bf,'Re',60);
% [ev,em] = SF_Stability(bf,'shift',0.04+.72i,'type','S');
% bf=SF_Adapt(bf,em,'Hmax',10,'InterpError',0.005);
% 
% disp(' ');
% disp('### Mesh grid size at point A,B,C,D : ');
% disp(['A : ' num2str(bf.mesh.deltaA)]);
% disp(['B : ' num2str(bf.mesh.deltaB)]);
% disp(['C : ' num2str(bf.mesh.deltaC)]);
% disp(['D : ' num2str(bf.mesh.deltaD)]);
% disp(' ' );
% 
% 
% bf=SF_BaseFlow(bf,'Re',40);
% [ev,em] = SF_Stability(bf,'shift',-0.03+.72i,'type','S');
% Re_Range = [40 : 5: 100];
% Drag_tab = []; Lx_tab = [];lambda_branch=[];
%     for Re = Re_Range
%         bf = SF_BaseFlow(bf,'Re',Re);
%         Drag_tab = [Drag_tab,bf.Cx];
%         Lx_tab = [Lx_tab,bf.Lx];
%         [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
%         lambda_branch = [lambda_branch ev];
%     end
% figure(80);    
% plot(Re_Range,real(lambda_branch));
% hold on;
% figure(81);
% plot(Re_Range,imag(lambda_branch));
% hold on;
% pause(0.1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ' );
% disp('### 5 : ADAPT ON SENSITIVITY (Re = 100)');
% disp(' ' );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% bf=SF_BaseFlow(bf,'Re',100);
% [ev,em] = SF_Stability(bf,'shift',.12+.73i,'type','S');
% bf=SF_Adapt(bf,em,'Hmax',10);
% 
% disp(' ');
% disp('### Mesh grid size at point A,B,C,D : ');
% disp(['A : ' num2str(bf.mesh.deltaA)]);
% disp(['B : ' num2str(bf.mesh.deltaB)]);
% disp(['C : ' num2str(bf.mesh.deltaC)]);
% disp(['D : ' num2str(bf.mesh.deltaD)]);
% disp(' ' );
% 
% 
% bf=SF_BaseFlow(bf,'Re',40);
% [ev,em] = SF_Stability(bf,'shift',-0.03+.72i,'type','S');
% Re_Range = [40 : 5: 100];
% Drag_tab = []; Lx_tab = [];lambda_branch=[];
%     for Re = Re_Range
%         bf = SF_BaseFlow(bf,'Re',Re);
%         Drag_tab = [Drag_tab,bf.Cx];
%         Lx_tab = [Lx_tab,bf.Lx];
%         [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
%         lambda_branch = [lambda_branch ev];
%     end
% figure(80);
% plot(Re_Range,real(lambda_branch));
% hold on;
% figure(81);
% plot(Re_Range,imag(lambda_branch));
% hold on;
% pause(0.1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ' );
% disp('### 6 : Slip conditions on lateral boundary');
% disp(' ' );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% bf=SF_Init('Mesh_Cylinder_SlipConditions.edp',[-40 80 40]);
% bf=SF_BaseFlow(bf,'Re',1);
% bf=SF_BaseFlow(bf,'Re',10);
% bf=SF_BaseFlow(bf,'Re',60);
% bf=SF_Adapt(bf,'Hmax',10);
% 
% [ev,em] = SF_Stability(bf,'shift',0.04+.72i,'type','S');
% bf=SF_Adapt(bf,em,'Hmax',10,'InterpError',0.01);
% 
% disp(' ');
% disp('### Mesh grid size at point A,B,C,D : ');
% disp(['A : ' num2str(bf.mesh.deltaA)]);
% disp(['B : ' num2str(bf.mesh.deltaB)]);
% disp(['C : ' num2str(bf.mesh.deltaC)]);
% disp(['D : ' num2str(bf.mesh.deltaD)]);
% disp(' ' );
% 
% 
% bf=SF_BaseFlow(bf,'Re',40);
% [ev,em] = SF_Stability(bf,'shift',-0.03+.72i,'type','S');
% Re_Range = [40 : 5: 100];
% Drag_tab = []; Lx_tab = [];lambda_branch=[];
%     for Re = Re_Range
%         bf = SF_BaseFlow(bf,'Re',Re);
%         Drag_tab = [Drag_tab,bf.Cx];
%         Lx_tab = [Lx_tab,bf.Lx];
%         [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
%         lambda_branch = [lambda_branch ev];
%     end
% figure(80);    
% plot(Re_Range,real(lambda_branch));
% hold on;
% figure(81);
% plot(Re_Range,imag(lambda_branch));
% hold on;
% pause(0.1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ' );
% disp('### 7 : VERY LARGE MESH');
% disp(' ' );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% 
% bf=SF_Init('Mesh_Cylinder.edp',[-80 160 80]);
% bf=SF_BaseFlow(bf,'Re',1);
% bf=SF_BaseFlow(bf,'Re',10);
% bf=SF_BaseFlow(bf,'Re',60);
% bf=SF_Adapt(bf,'Hmax',10);
% bf=SF_Adapt(bf,'Hmax',10);
% 
% bf=SF_BaseFlow(bf,'Re',60);
% [ev,em] = SF_Stability(bf,'shift',0.04+.72i,'type','S');
% bf=SF_Adapt(bf,em,'Hmax',10);
% 
% 
% 
% disp(' ');
% disp('### Mesh grid size at point A,B,C,D : ');
% disp(['A : ' num2str(bf.mesh.deltaA)]);
% disp(['B : ' num2str(bf.mesh.deltaB)]);
% disp(['C : ' num2str(bf.mesh.deltaC)]);
% disp(['D : ' num2str(bf.mesh.deltaD)]);
% disp(' ' );
% 
% bf=SF_BaseFlow(bf,'Re',40);
% [ev,em] = SF_Stability(bf,'shift',-0.03+.72i,'type','S');
% 
% Drag_tab = []; Lx_tab = [];lambda_branch=[];
% Re_Range = [40 : 5: 100];
%     for Re = Re_Range
%         bf = SF_BaseFlow(bf,'Re',Re);
%         Drag_tab = [Drag_tab,bf.Cx];
%         Lx_tab = [Lx_tab,bf.Lx];
%         [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
%         lambda_branch = [lambda_branch ev];
%     end
% figure(80);
% plot(Re_Range,real(lambda_branch));
% hold on;
% figure(81);
% plot(Re_Range,imag(lambda_branch));
% hold on;
% pause(0.1);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ' );
% disp('### 8 : SMALLER MESH');
% disp(' ' );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% bf=SF_Init('Mesh_Cylinder.edp',[-20 40 20]);
% bf=SF_BaseFlow(bf,'Re',1);
% bf=SF_BaseFlow(bf,'Re',10);
% bf=SF_BaseFlow(bf,'Re',60);
% bf=SF_Adapt(bf,'Hmax',10);
% bf=SF_Adapt(bf,'Hmax',10);
% 
% bf=SF_BaseFlow(bf,'Re',60);
% [ev,em] = SF_Stability(bf,'shift',0.04+.72i,'type','S');
% bf=SF_Adapt(bf,em,'Hmax',10);
% 
% 
% disp(' ');
% disp('### Mesh grid size at point A,B,C,D : ');
% disp(['A : ' num2str(bf.mesh.deltaA)]);
% disp(['B : ' num2str(bf.mesh.deltaB)]);
% disp(['C : ' num2str(bf.mesh.deltaC)]);
% disp(['D : ' num2str(bf.mesh.deltaD)]);
% disp(' ' );
% 
% bf=SF_BaseFlow(bf,'Re',40);
% [ev,em] = SF_Stability(bf,'shift',-0.03+.72i,'type','S');
% 
% Re_Range = [40 : 2 : 100];
% Drag_tab = []; Lx_tab = [];lambda_branch=[];
%     for Re = Re_Range
%         bf = SF_BaseFlow(bf,'Re',Re);
%         Drag_tab = [Drag_tab,bf.Cx];
%         Lx_tab = [Lx_tab,bf.Lx];
%         [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
%         lambda_branch = [lambda_branch ev];
%     end
% figure(80);    
% plot(Re_Range,real(lambda_branch));
% hold on;
% figure(81);
% plot(Re_Range,imag(lambda_branch));
% hold on;
% pause(0.1);
% 
% 
% %%% FINALIZATION OF THE FIGURES
% 
% figure(80);
% xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
% legend('Adapt to BF', 'Ref', 'Adapt to mode', 'Err=0.005', 'Adapt for Re=100','Slip BC','[-80,240]x[0,80]','[-20,40]x[0,20]');
% box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.8;set(gcf,'Position',pos); % resize aspect ratio
% set(gca,'FontSize', 16);
% legend('Location','SouthEast')
% saveas(gca,'Cylinder_Sigma_Re_TESTMESHES',figureformat);
% 
% figure(81);
% xlabel('Re');ylabel('St');
% box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.8;set(gcf,'Position',pos); % resize aspect ratio
% legend('Adapt to BF', 'Ref', 'Adapt to mode', 'Err=0.005', 'Adapt for Re=100','Slip BC','[-80,240]x[0,80]','[-20,40]x[0,20]');
% legend('Location','South')
% set(gca,'FontSize', 18);
% saveas(gca,'Cylinder_Strouhal_Re_TESTMESHES',figureformat);
% pause(0.1);
%     
% 
