%  Instability of the wake of a cylinder with STABFEM  
%
%  this scripts performs the following calculations :
%  1/ Generation of an adapted mesh
%  2/ Base-flow properties for Re = [2-40]
%  3/ Stability curves St(Re) and sigma(Re) for Re = [40-100]
%  4/ Determination of the instability threshold
%  5/ Harmonic-Balance for Re = REc-100
%  6/ Self-consistent model for Re=100

% CHAPTER 0 : set the global variables needed by the drivers

global ff ffdir ffdatadir sfdir verbosity
%ff = '/PRODCOM/FREEFEM/Ubuntu12.04/3.29/bin/FreeFem++-nw'; % on IMFT network
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw'; % on DF's macbookpro 
ffdatadir = './WORK/';
sfdir = '../SOURCES_MATLAB/'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts
verbosity = 1;
addpath(sfdir);
system(['mkdir ' ffdatadir]);
figureformat='png'; AspectRatio = 0.56; % for figure

%##### CHAPTER 1 : COMPUTING THE MESH WITH ADAPTMESH PROCEDURE

if(exist('baseflow')==1)
disp(' ADAPTMESH PROCEDURE WAS PREVIOUSLY DONE, START WITH EXISTING MESH : '); 
baseflow=SF_BaseFlow(baseflow,60);
[ev,em] = SF_Stability(baseflow,'shift',0.04+0.76i,'nev',1,'type','S');
else
   
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');
disp(' LARGE MESH : [-40:80]x[0:40] ');
disp(' ');    
baseflow=SF_Init('Mesh_Cylinder_Large.edp');
baseflow=SF_BaseFlow(baseflow,1);
baseflow=SF_BaseFlow(baseflow,10);
baseflow=SF_BaseFlow(baseflow,60);
baseflow=SF_Adapt(baseflow,'Hmax',5);
baseflow=SF_Adapt(baseflow,'Hmax',5);
disp(' ');
disp('mesh adaptation to SENSITIVITY : ')
[ev,em] = SF_Stability(baseflow,'shift',0.04+0.76i,'nev',1,'type','S');
[baseflow,em]=SF_Adapt(baseflow,em,'Hmax',10);

end

%%% CHAPTER 1b : DRAW FIGURES

% plot the mesh (full size)
plotFF(baseflow,'mesh');
title('Adapted mesh (full size)');
box on; %pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh_Full',figureformat); 

% plot the mesh (zoom)
baseflow.xlim = [-2 4]; baseflow.ylim=[0,3];
plotFF(baseflow,'mesh');
title('Adapted mesh (zoom)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh',figureformat);
    
% plot the base flow
baseflow.xlim = [-2 4]; baseflow.ylim=[0,3];
plotFF(baseflow,'ux');
title('Base flow at Re=60 (axial velocity)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_BaseFlowRe60',figureformat);


em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1');
title('Eigenmode at Re=60 (ADAPT TO SENSITIVITY)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_EigenModeRe60_AdaptS',figureformat);  % 

em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1Adj');
title('Adjoint Eigenmode at Re=60 (axial velocity component)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_EigenModeAdjRe60',figureformat);

em.xlim = [-2 4]; em.ylim=[0,3];
plotFF(em,'sensitivity');
title('Structural sensitivity at Re=60');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SensitivityRe60',figureformat);



%%%% CHAPTER 2 : DESCRIPTION OF BASE FLOW PROPERTIES (range 2-50)

if(exist('Re_RangeB')==0)

Re_RangeB = [2 : 2: 50];
Drag_tabB = []; Lx_tabB = [];
    for Re = Re_RangeB
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tabB = [Drag_tabB,baseflow.Drag];
        Lx_tabB = [Lx_tabB,baseflow.Lx];
    end
    
end

%%% chapter 2B : figures
 
figure(22);hold off;
plot(Re_RangeB,Drag_tabB,'b+-');
xlabel('Re');ylabel('Drag');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Drag_baseflow',figureformat);

figure(23);hold off;
plot(Re_RangeB,Lx_tabB,'b+-');
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Lx_baseflow',figureformat);


pause(0.1);


%%% CHAPTER 3 : COMPUTING STABILITY BRANCH

if(exist('lambda_branch')==1)
    disp('STABILITY BRANCH ALREADY COMPUTED')
else
    disp('COMPUTING STABILITY BRANCH')

% LOOP OVER RE FOR BASEFLOW + EIGENMODE
Re_Range = [40 : 2: 100];
baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-.03+.72i,'nev',1,'type','D');

Drag_tab = []; Lx_tab = [];lambda_branch=[];
    for Re = Re_Range
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Drag_tab = [Drag_tab,baseflow.Drag];
        Lx_tab = [Lx_tab,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end    
end


%%% CHAPTER 3b : figures

figure(20);
plot(Re_Range,real(lambda_branch),'b+-');
xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Sigma_Re',figureformat);

figure(21);hold off;
plot(Re_Range,imag(lambda_branch)/(2*pi),'b+-');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Strouhal_Re',figureformat);
pause(0.1);
    
figure(22);hold off;
set(gca,'FontSize', 18);
xlabel('Re');ylabel('Drag');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
%saveas(gca,'Cylinder_Drag_baseflow',figureformat);

figure(23);hold off;
plot(Re_Range,Lx_tab,'b+-');
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); %pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
%saveas(gca,'Cylinder_Lx_baseflow',figureformat);
pause(0.1);


%%% CHAPTER 4 : determination of critical reynolds number

if(exist('Rec')==1)
    disp('INSTABILITY THRESHOLD ALREADY COMPUTED');
else 
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
baseflow=SF_BaseFlow(baseflow,'Re',50);
[ev,em] = SF_Stability(baseflow,'shift',+.75i,'nev',1,'type','D');
[baseflow,em]=SF_FindThreshold(baseflow,em);
Rec = baseflow.Re;  Dragc = baseflow.Drag; 
Lxc=baseflow.Lx;    Omegac=imag(em.lambda);
%[ev,em] = SF_Stability(baseflow,'shift',em.lambda,'type','S','nev',1);
end




%%% CHAPTER 5 : HARMONIC BALANCE

if(exist('Lxtab')==1)
    disp('Harmonic balance on the range [Rec , 100] already computed');
else
    disp('Computing Harmonic balance on the range [Rec , 100]');
Retab = [Rec 47.5 48 49 50 55 60 65 70 75 80 85 90 95 100];
Dragtab = [Dragc]; Lxtab = [Lxc]; omegatab = [Omegac]; Aenergytab = [0]; Lifttab = [0];

baseflow=SF_BaseFlow(baseflow,47.5);
[ev,em] = SF_Stability(baseflow,'shift',Omegac*i);
[meanflow,mode] = SF_HarmonicBalance(baseflow,em,'sigma',0.,'Re',47.5,'Aguess',0.4);

for Re = Retab(2:end)
    [meanflow,mode] = SF_HarmonicBalance(meanflow,mode,'Re',Re);
    Lxtab = [Lxtab meanflow.Lx];
    Dragtab = [Dragtab meanflow.Drag];
    omegatab = [omegatab imag(mode.lambda)];
    Aenergytab  = [Aenergytab mode.Energy];
    Lifttab = [Lifttab mode.Lift];
end
   
end


%%% chapter 5b : figures

figure(21);hold off;
plot(Re_Range,imag(lambda_branch)/(2*pi),'b+-');hold on;
plot(Retab,omegatab/(2*pi),'r+-');
plot(Rec,Omegac/2/pi,'ro');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','HB','Location','northwest');
saveas(gca,'Cylinder_Strouhal_Re_HB',figureformat);

figure(22);hold off;
plot(Re_Range,Drag_tab,'b+-');hold on;
plot(Retab,Dragtab,'r+-');
plot(Rec,Dragc,'ro')
xlabel('Re');ylabel('Drag');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','HB','Location','northwest');
saveas(gca,'Cylinder_Drag_Re_HB',figureformat);

figure(23);hold off;
plot(Re_Range,Lx_tab,'b+-');hold on;
plot(Retab,Lxtab,'r+-');
plot(Rec,Lxc,'ro');
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','HB','Location','northwest');
saveas(gca,'Cylinder_Lx_Re_HB',figureformat);

figure(24);hold on;
plot(Retab,real(Lifttab),'r+-');
title('Harmonic Balance results');xlabel('Re');ylabel('Lift')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Lift_Re_SC',figureformat);

figure(25);hold on;
plot(Retab,Aenergytab,'r+-');
title('Harmonic Balance results');xlabel('Re');ylabel('A')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Energy_Re_SC',figureformat);

pause(0.1);




%%% CHAPTER 6 : SELFCONSISTENT APPROACH WITH RE = 100

if(exist('LiftSC_tab')==1)
    disp(' SC model for Re=100 : calculation already done');
else
    disp(' COMPUTING SC model for Re=100');
% determination of meanflow/selfconsistentmode for Re = 100

baseflow=SF_BaseFlow(baseflow,100);
[ev,em] = SF_Stability(baseflow,'shift',0.12+0.72i,'nev',1,'type','D');
lambdaSC_tab = [real(em.lambda),0.12:-.0025:0];

LiftSC_tab = [0]; EnergySC_tab = [0];
[meanflow,mode] = SF_HarmonicBalance(baseflow,em,'sigma',0.12,'Lguess',0.0078)
for lambdaSC = lambdaSC_tab(2:end)
    [meanflow,mode] = SF_HarmonicBalance(meanflow,mode,'sigma',lambdaSC)
    LiftSC_tab = [LiftSC_tab mode.Lift];
    EnergySC_tab = [EnergySC_tab mode.Energy];
end

end

figure(31);hold on;
plot(lambdaSC_tab,real(LiftSC_tab),'b-+');
xlabel('sigma');ylabel('Lift');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SC100_LiftSigma',figureformat);


figure(32);hold on;
plot(EnergySC_tab,lambdaSC_tab,'b-+');
ylabel('$\sigma$','Interpreter','latex');xlabel('A');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SC100_EnergySigma',figureformat);

