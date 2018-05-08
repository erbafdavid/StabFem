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
close all;
run('../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures


%##### CHAPTER 1 : COMPUTING THE MESH WITH ADAPTMESH PROCEDURE

if(exist('mesh_completed')==1)
disp(' ADAPTMESH PROCEDURE AS PREVIOUSLY DONE, START WITH EXISTING MESH : '); 
bf=SF_BaseFlow(bf,'Re',60);
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type','S');
else
   
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');
disp(' LARGE MESH : [-40:80]x[0:40] ');
disp(' ');    
bf=SF_Init('Mesh_Cylinder.edp',[-40 80 40]);
bf=SF_BaseFlow(bf,'Re',1);
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_Adapt(bf,'Hmax',5);
disp(' ');
disp('mesh adaptation to SENSITIVITY : ')
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type','S');
[bf,em]=SF_Adapt(bf,em,'Hmax',10);
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
bf.xlim = [-2 4]; bf.ylim=[0,3];
plotFF(bf,'mesh');
title('Initial mesh (zoom)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh',figureformat);
    
% plot the base flow
bf.xlim = [-2 4]; bf.ylim=[0,3];
plotFF(bf,'ux');
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
plot(Re_BF,Fx_BF*2,'b+-','LineWidth',2);
xlabel('Re');ylabel('Cx');
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
bf=SF_BaseFlow(bf,'Re',40);
[ev,em] = SF_Stability(bf,'shift',-.03+.72i,'nev',1,'type','D');

Fx_LIN = []; Lx_LIN = [];lambda_LIN=[];
    for Re = Re_LIN
        bf = SF_BaseFlow(bf,'Re',Re);
        Fx_LIN = [Fx_LIN,bf.Fx];
        Lx_LIN = [Lx_LIN,bf.Lx];
        [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
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
    
figure(22);hold off;
set(gca,'FontSize', 18);
xlabel('Re');ylabel('Cx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
%saveas(gca,'Cylinder_Cx_baseflow',figureformat);

figure(23);hold off;
plot(Re_LIN,Lx_LIN,'b+-');
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); %pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
%saveas(gca,'Cylinder_Lx_baseflow',figureformat);
pause(0.1);




%%% CHAPTER 3 : computation of weakly nonlinear expansion

%bf=SF_BaseFlow(bf,'Re',50);

if(exist('Rec')==1)
    disp('INSTABILITY THRESHOLD ALREADY COMPUTED');
    bf=SF_BaseFlow(bf,'Re',Rec);
    [ev,em] = SF_Stability(bf,'shift',em.lambda,'type','S','nev',1);
else 
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
bf=SF_BaseFlow(bf,'Re',50);
[ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','D');
[bf,em]=SF_FindThreshold(bf,em);
Rec = bf.Re;  Fxc = bf.Fx; 
Lxc=bf.Lx;    Omegac=imag(em.lambda);
%[ev,em] = SF_Stability(bf,'shift',em.lambda,'type','S','nev',1);
end



[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S'); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,'Retest',47.); % Here to generate a starting point for the next chapter

%%% PLOTS of WNL predictions

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2;
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
xlabel('Re');ylabel('Cx');

figure(24); hold on;
plot(Re_WNL,Fy_WNL,'g--','LineWidth',2);
xlabel('Re');ylabel('Cy')

figure(25);hold on;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
xlabel('Re');ylabel('AE')

pause;



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

[meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'sigma',0.,'Re',47.5); 

for Re = Re_HB(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',Re);
    Lx_HB = [Lx_HB meanflow.Lx];
    Fx_HB = [Fx_HB meanflow.Fx];
    omega_HB = [omega_HB imag(mode.lambda)];
    Aenergy_HB  = [Aenergy_HB mode.AEnergy];
    Fy_HB = [Fy_HB mode.Fy];
end
HB_completed = 1;   
end

%%% chapter 5b : figures

figure(21);hold off;
plot(Re_LIN,imag(lambda_LIN)/(2*pi),'b+-');
hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--','LineWidth',2);hold on;
plot(Re_HB,omega_HB/(2*pi),'r+-','LineWidth',2);
plot(Rec,Omegac/2/pi,'ro');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','WNL','SC','Location','northwest');
saveas(gca,'Cylinder_Strouhal_Re_HB',figureformat);

figure(22);hold off;
plot(Re_LIN,2*Fx_LIN,'b+-');
hold on;
plot(Re_WNL,2*Fx_WNL,'g--','LineWidth',2);hold on;
plot(Re_HB,2*Fx_HB,'r+-','LineWidth',2);
plot(Rec,2*Fxc,'ro')
xlabel('Re');ylabel('Cx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','WNL','SC','Location','south');
saveas(gca,'Cylinder_Cx_Re_HB',figureformat);

figure(23);hold off;
plot(Re_LIN,Lx_LIN,'b+-');
hold on;
plot(Re_HB,Lx_HB,'r+-','LineWidth',2);
plot(Rec,Lxc,'ro','LineWidth',2);
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','SC','Location','northwest');
saveas(gca,'Cylinder_Lx_Re_HB',figureformat);

figure(24);hold off;
plot(Re_WNL,2*Fy_WNL,'g--','LineWidth',2);
hold on;
plot(Re_HB,2*real(Fy_HB),'r+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');  ylabel('Cy')
box on;  pos = get(gcf,'Position');  pos(4)=pos(3)*AspectRatio;  set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','SC','Location','south');
saveas(gca,'Cylinder_Cy_Re_SC',figureformat);

figure(25);hold off;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
hold on;
plot(Re_HB,Aenergy_HB,'r+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('A_E')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio; set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','SC','Location','south');
saveas(gca,'Cylinder_Energy_Re_SC',figureformat);
save('Results_Cylinder.mat');


