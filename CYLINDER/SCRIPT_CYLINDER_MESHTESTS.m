%  Instability of the wake of a cylinder with STABFEM  
%
%  THIS SCRIPT COMPARES THE RESULTS OBTAINED WITH 7 DIFFERENT MESHES

% CHAPTER 0 : set the global variables needed by the drivers

global ff ffdir ffdatadir sfdir verbosity
%ff = '/PRODCOM/FREEFEM/Ubuntu12.04/3.29/bin/FreeFem++-nw -v 0'; % on IMFT network
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw -v 0'; % on DF's macbookpro 
ffdatadir = './WORK/';
sfdir = '../SOURCES_MATLAB/'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts
verbosity = 1;
addpath(sfdir);
system(['mkdir ' ffdatadir]);
figureformat='png'; AspectRatio = 0.56; % for figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');    
disp('### 1 : MESH based on base flow : ');     
disp(' ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


baseflow=SF_Init('Mesh_Cylinder_Large.edp');
baseflow=SF_BaseFlow(baseflow,1);
baseflow=SF_BaseFlow(baseflow,10);
baseflow=SF_BaseFlow(baseflow,60);
baseflow=SF_Adapt(baseflow,'Hmax',10);
baseflow=SF_Adapt(baseflow,'Hmax',10);

disp(' ' );
disp('### 1 : ADAPT ON BASE FLOW');
disp(' ' );

baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');
Re_Range = [40 : 5: 100];
Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end    
figure(80);
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 2 : ADAPT ON SENSITIVITY (ref case)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baseflow=SF_BaseFlow(baseflow,'Re',60);
[ev,em] = SF_Stability(baseflow,'shift',0.04+.72i,'type','S');
baseflow=SF_Adapt(baseflow,em,'Hmax',10);

baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');
Re_Range = [40 : 5: 100];
Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end    
figure(80);    
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 3 : ADAPT ON MODE');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


baseflow=SF_BaseFlow(baseflow,'Re',60);
[ev,em] = SF_Stability(baseflow,'shift',.04+.72i,'type','D');
baseflow=SF_Adapt(baseflow,em,'Hmax',10);
[ev,em] = SF_Stability(baseflow,'shift','prev','type','D');

% create figure for this mode;
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1');
title('Eigenmode at Re=60');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.56;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_EigenModeRe60',figureformat);

% loop
Re_Range = [40 : 5: 100];
baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');
Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end
figure(80);    
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 4 : ADAPT ON SENSITIVITY (err = 0.005)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


baseflow=SF_BaseFlow(baseflow,'Re',60);
[ev,em] = SF_Stability(baseflow,'shift',0.04+.72i,'type','S');
baseflow=SF_Adapt(baseflow,em,'Hmax',10,'InterpError',0.005);


baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');
Re_Range = [40 : 5: 100];
Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end
figure(80);    
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 5 : ADAPT ON SENSITIVITY (Re = 100)');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


baseflow=SF_BaseFlow(baseflow,'Re',100);
[ev,em] = SF_Stability(baseflow,'shift',.12+.73i,'type','S');
baseflow=SF_Adapt(baseflow,em,'Hmax',10);

baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');
Re_Range = [40 : 5: 100];
Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end
figure(80);
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 6 : Slip conditions on lateral boundary');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

system('cp Macros_StabFem_LateralSlip.edp Macros_StabFem.edp');
system(['rm ',ffdatadir,'BASEFLOWS/*']);

baseflow=SF_BaseFlow(baseflow,'Re',60.1); % 60.1 to force recomputation
[ev,em] = SF_Stability(baseflow,'shift',0.04+.72i,'type','S');
baseflow=SF_Adapt(baseflow,em,'Hmax',10,'InterpError',0.01);

baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');
Re_Range = [40 : 5: 100];
Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end
figure(80);    
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 7 : VERY LARGE MESH');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
system('cp Macros_StabFem_LateralNeuman.edp Macros_StabFem.edp');


baseflow=SF_Init('Mesh_Cylinder_VeryLarge.edp');
baseflow=SF_BaseFlow(baseflow,1);
baseflow=SF_BaseFlow(baseflow,10);
baseflow=SF_BaseFlow(baseflow,60);
baseflow=SF_Adapt(baseflow,'Hmax',10);
baseflow=SF_Adapt(baseflow,'Hmax',10);

baseflow=SF_BaseFlow(baseflow,'Re',60);
[ev,em] = SF_Stability(baseflow,'shift',0.04+.72i,'type','S');
baseflow=SF_Adapt(baseflow,em,'Hmax',10);

baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');

Drag_tab = []; Lx_tab = [];lambda_branch=[];
Re_Range = [40 : 5: 100];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end
figure(80);
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ' );
disp('### 8 : SMALLER MESH');
disp(' ' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


baseflow=SF_Init('Mesh_Cylinder.edp');
baseflow=SF_BaseFlow(baseflow,1);
baseflow=SF_BaseFlow(baseflow,10);
baseflow=SF_BaseFlow(baseflow,60);
baseflow=SF_Adapt(baseflow,'Hmax',10);
baseflow=SF_Adapt(baseflow,'Hmax',10);

baseflow=SF_BaseFlow(baseflow,'Re',60);
[ev,em] = SF_Stability(baseflow,'shift',0.04+.72i,'type','S');
baseflow=SF_Adapt(baseflow,em,'Hmax',10);

baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-0.03+.72i,'type','S');

Re_Range = [40 : 2 : 100];
Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end
figure(80);    
plot(Re_Range,real(lambda_branch));
hold on;
figure(81);
plot(Re_Range,imag(lambda_branch));
hold on;
pause(0.1);


%%% FINALIZATION OF THE FIGURES

figure(80);
xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
legend('Adapt to BF', 'Ref', 'Adapt to mode', 'Err=0.005', 'Adapt for Re=100','Slip BC','[-80,240]x[0,80]','[-20,40]x[0,20]');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.8;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 16);
saveas(gca,'Cylinder_Sigma_Re_TESTMESHES',figureformat);

figure(81);
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.8;set(gcf,'Position',pos); % resize aspect ratio
legend('Adapt to BF', 'Ref', 'Adapt to mode', 'Err=0.005', 'Adapt for Re=100','Slip BC','[-80,240]x[0,80]','[-20,40]x[0,20]');
legend('Location','South')
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Strouhal_Re_TESTMESHES',figureformat);
pause(0.1);
    

