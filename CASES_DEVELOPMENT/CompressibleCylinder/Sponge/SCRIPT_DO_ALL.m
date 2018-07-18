%  Instability of the wake of a cylinder with STABFEM  
%
%  this scripts performs the following calculations :
%  1/ Generation of an adapted mesh
%  2/ Base-flow properties for Re = [2-40]
%  3/ Stability curves St(Re) and sigma(Re) for Re = [40-100]
%  4/ Determination of the instability threshold and Weakly-Nonlinear
%  analysis
%  5/ Harmonic-Balance for Re = REc-100
%  6/ Self-consistent model for Re=100

% CHAPTER 0 : set the global variables needed by the drivers

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;

% parameters for mesh creation 
% Outer Domain 
xinfm=-40.; xinfv=80.; yinf=40.;
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=30.;y2=10;
% Sponge extension
ls=300.0; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=100; % Refinement density around the cylinder
n1=7; % Density in the inner domain
n2=3; % Density in the middle domain
ns=0.15; % Density in the outer domain
nsponge=.15; % density in the sponge region

%Compressibility to create a mesh 
Ma = 0.1


disp(' '); 
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');



if(exist('mesh_completed')==1)
disp(' ADAPTMESH PROCEDURE AS PREVIOUSLY DONE, START WITH EXISTING MESH : '); 
bf=SF_BaseFlow(bf,'Re',47,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',0.001 + 0.732i,'nev',1,'type','D','sym','N','Ma',Ma);
else
bf = SF_Init('Mesh.edp',[xinfm,xinfv,yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
bf=SF_BaseFlow(bf,'Re',1,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',10);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',10);
bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.041 + 0.735i,'nev',1,'type','S','sym','N','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.041 + 0.735i,'nev',1,'type','S','sym','N','Ma',Ma);
mesh_completed = 1;
end


%%% CHAPTER 1b : DRAW FIGURES

% plot the mesh (full size)
plotFF(bf,'mesh');
title('Initial mesh (full size)');
box on; %pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh_Full',figureformat); 

% plot the mesh (zoom)
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'mesh');
title('Initial mesh (zoom)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh',figureformat);
    
% plot the base flow for Re = 60
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'ux','Contour','on','Levels',[0 0]);
%plotFF(bf,'ux');
title('Base flow at Re=60 (axial velocity)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_BaseFlowRe60',figureformat);


% plot the eigenmode for Re = 60
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1');
title('Eigenmode for Re=60');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_EigenModeRe60_AdaptS',figureformat);  % 

em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1Adj');
title('Adjoint Eigenmode for Re=60');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_EigenModeAdjRe60',figureformat);

em.xlim = [-2 4]; em.ylim=[0,3];
plotFF(em,'sensitivity');
title('Structural sensitivity for Re=60');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SensitivityRe60',figureformat);


%%%% CHAPTER 2 : DESCRIPTION OF BASE FLOW PROPERTIES (range 2-50)

if(exist('completed_Cx')==0)

Re_BF = [2 : 2: 50];
Fx_BF = []; Lx_BF = [];
    for Re = Re_BF
        bf = SF_BaseFlow(bf,'Re',Re);
        Fx_BF = [Fx_BF,bf.Fx];
        Lx_BF = [Lx_BF,bf.Lx];
    end
completed_Cx = 1;    
end

%%% chapter 2B : figures
 
figure(22);hold off;
plot(Re_BF,Fx_BF,'b+-','LineWidth',2);
xlabel('Re');ylabel('Fx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Cx_baseflow',figureformat);

figure(23);hold off;
plot(Re_BF,Lx_BF,'b+-','LineWidth',2);
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Lx_baseflow',figureformat);


pause(0.1);



%%% CHAPTER 3 : COMPUTING STABILITY BRANCH

if(exist('completed_lambda')==1)
    disp('STABILITY BRANCH ALREADY COMPUTED')
else
    disp('COMPUTING STABILITY BRANCH')

% LOOP OVER RE FOR BASEFLOW + EIGENMODE
Re_LIN = [40 : 2: 100];
bf=SF_BaseFlow(bf,'Re',40,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',-.05+.68i,'nev',1,'type','D','sym','N','Ma',Ma);

Fx_LIN = []; Lx_LIN = [];lambda_LIN=[];
    for Re = Re_LIN
        bf = SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
        Fx_LIN = [Fx_LIN,bf.Fx];
        Lx_LIN = [Lx_LIN,bf.Lx];
        [ev,em] = SF_Stability(bf,'nev',1,'shift','cont','sym','N','Ma',Ma);
        lambda_LIN = [lambda_LIN ev];
    end  
completed_lambda = 1;
end



%%% CHAPTER 3b : figures

figure(20);
plot(Re_LIN,real(lambda_LIN),'b+-');
xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Sigma_Re',figureformat);

figure(21);hold off;
plot(Re_LIN,imag(lambda_LIN)/(2*pi),'b+-');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Strouhal_Re',figureformat);
pause(0.1);
    
%figure(22);hold off;
%set(gca,'FontSize', 18);
%xlabel('Re');ylabel('Fx');
%box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
%set(gca,'FontSize', 18);
%saveas(gca,'Cylinder_Cx_baseflow',figureformat);

%figure(23);hold off;
%plot(Re_LIN,Lx_LIN,'b+-');
%xlabel('Re');ylabel('Lx');
%box on; pos = get(gcf,'Position'); %pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
%set(gca,'FontSize', 18);
%saveas(gca,'Cylinder_Lx_baseflow',figureformat);
%pause(0.1);


tlin = tic;
disp(' ');
disp('       cpu time for Linear calculations : ');
disp([ '   ' num2str(tlin-tinit) ' seconds']);




%%% CHAPTER 4 : computation of weakly nonlinear expansion

% 4a : adapt mesh to eigenmode (mesh M4 of the appendix)
bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
disp('mesh adaptation to EIGENMODE : ')
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type','D','sym','N','Ma',Ma);
bf=SF_Adapt(bf,em,'Hmax',10);
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type','D','sym','N','Ma',Ma);
% plot the eigenmode for Re = 60
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1','colorrange',[-.5 .5]);
title('Eigenmode for Re=60');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_EigenModeRe60_AdaptD',figureformat);  % 


if(exist('Rec')==1)
    disp('INSTABILITY THRESHOLD ALREADY COMPUTED');
    bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
    [ev,em] = SF_Stability(bf,'shift',em.lambda,'type','S','nev',1,'sym','N','Ma',Ma);
else 
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
bf=SF_BaseFlow(bf,'Re',50,'Ma',Ma);
[ev,em] = SF_Stability(bf,'shift',+.73i,'nev',1,'type','D','sym','N','Ma',Ma);
[bf,em]=SF_FindThreshold(bf,em);
Rec = bf.Re;  Fxc = bf.Fx; 
Lxc=bf.Lx;    Omegac=imag(em.lambda);
%[ev,em] = SF_Stability(bf,'shift',em.lambda,'type','S','nev',1);
end



[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','N','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.,'Normalization','V'); % Here to generate a starting point for the next chapter



%%% PLOTS of WNL predictions

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

figure(20);hold on;
plot(Re_WNL,real(wnl.Lambda)*epsilon2_WNL,'g--','LineWidth',2);hold on;

figure(21);hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--','LineWidth',2);hold on;
xlabel('Re');ylabel('St');

figure(22);hold on;
plot(Re_WNL,Fx_WNL,'g--','LineWidth',2);hold on;
xlabel('Re');ylabel('Fx');

figure(24); hold on;
plot(Re_WNL,abs(Fy_WNL),'g--','LineWidth',2);
xlabel('Re');ylabel('Fy')

figure(25);hold on;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
xlabel('Re');ylabel('AE')

pause(0.1);


%%% CHAPTER 5 : SELF CONSISTENT

if(exist('HB_completed')==1)
    disp('SC quasilinear model on the range [Rec , 100] already computed');
else
    disp('SC quasilinear model on the range [Rec , 100]');
Re_HB = [Rec 47 47.5 48 49 50 52.5 55 60 65 70 75 80 85 90 95 100];



%%% THE STARTING POINT HAS BEEN GENERATED ABOVE, WHEN PERFORMING THE WNL
%%% ANALYSIS
Res = 47. ; 

 Lx_HB = [Lxc]; Fx_HB = [Fxc]; omega_HB = [Omegac]; Aenergy_HB  = [0]; Fy_HB = [0];
%bf=SF_BaseFlow(bf,'Re',Res);
%[ev,em] = SF_Stability(bf,'shift',Omegac*i);

[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'sigma',0.,'Re',47.); 

for Re = Re_HB(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',Re);
    Lx_HB = [Lx_HB meanflow.Lx];
    Fx_HB = [Fx_HB meanflow.Fx];
    omega_HB = [omega_HB imag(mode.lambda)];
    Aenergy_HB  = [Aenergy_HB mode.AEnergy];
    Fy_HB = [Fy_HB mode.Fy];
    
    if(Re==60)
       meanflow.xlim = [-2 4]; meanflow.ylim=[0,3];
       plotFF(meanflow,'ux','contour','on','levels',[0 0]);
%       plotFF(meanflow,'ux');
       title('Mean flow at Re=60 (axial velocity)');
       box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
       set(gca,'FontSize', 18);
       saveas(gca,'Cylinder_MeanFlowRe60',figureformat); 
    end
end
HB_completed = 1;   
end

%%% chapter 5b : figures

figure(21);hold off;
plot(Re_LIN,imag(lambda_LIN)/(2*pi),'b+-');
hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--','LineWidth',2);hold on;
plot(Re_HB,omega_HB/(2*pi),'r+-','LineWidth',2);
plot(Re_HB2,omega_HB2/(2*pi),'r+-','LineWidth',2);
plot(Re_HB,omega_HB/(2*pi),'b+-','LineWidth',2);
plot(Rec,Omegac/2/pi,'ro');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','WNL','SC','SC M=0.2','Location','northwest');
saveas(gca,'Cylinder_Strouhal_Re_HB',figureformat);

figure(22);hold off;
plot(Re_LIN,Fx_LIN,'b+-');
hold on;
plot(Re_WNL,Fx_WNL,'g--','LineWidth',2);hold on;
plot(Re_HB,Fx_HB,'r+-','LineWidth',2);
plot(Rec,Fxc,'ro')
xlabel('Re');ylabel('Fx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','WNL','SC','Location','south');
saveas(gca,'Cylinder_Cx_Re_HB',figureformat);

figure(23);hold off;
plot(Re_LIN,Lx_LIN,'b+-');
hold on;
plot(Re_HB2,Lx_HB2,'r+-','LineWidth',2);
plot(Re_HB,Lx_HB,'b+-','LineWidth',2);
plot(Rec,Lxc,'ro','LineWidth',2);
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','SC','SC M=0.2','Location','northwest');
saveas(gca,'Cylinder_Lx_Re_HB',figureformat);

figure(24);hold off;
plot(Re_WNL,abs(Fy_WNL),'g--','LineWidth',2);
hold on;
plot(Re_HB2,real(Fy_HB2),'r+-','LineWidth',2);
plot(Re_HB,real(Fy_HB),'b+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');  ylabel('Fy')
box on;  pos = get(gcf,'Position');  pos(4)=pos(3)*AspectRatio;  set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','SC','SC M=0.2','Location','south');
saveas(gca,'Cylinder_Cy_Re_SC',figureformat);

figure(25);hold off;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
hold on;
plot(Re_HB2,Aenergy_HB2,'r+-','LineWidth',2);
plot(Re_HB,1.25*Aenergy_HB,'b+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('A_E')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio; set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','SC','SC M=0.2','Location','south');
saveas(gca,'Cylinder_Energy_Re_SC',figureformat);


tfinal = tic;
disp(' ');
disp('       cpu time for Nonlinear calculations : ');
disp([ '   ' num2str(tfinal-tlin) ' seconds']);

disp(' ');
disp('Total cpu time for the linear & nonlinear calculations and generation of all figures : ');
disp([ '   ' num2str(tfinal-tinit) ' seconds']);


save('Results_Cylinder.mat');