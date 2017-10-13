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

if(exist('Cx_BF')==0)

Re_BF = [2 : 2: 50];
Cx_BF = []; Lx_BF = [];
    for Re = Re_BF
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Cx_BF = [Cx_BF,baseflow.Cx];
        Lx_BF = [Lx_BF,baseflow.Lx];
    end
    
end

%%% chapter 2B : figures
 
figure(22);hold off;
plot(Re_BF,Cx_BF,'b+-');
xlabel('Re');ylabel('Cx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Cx_baseflow',figureformat);

figure(23);hold off;
plot(Re_BF,Lx_BF,'b+-');
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Lx_baseflow',figureformat);


pause(0.1);


%%% CHAPTER 3 : COMPUTING STABILITY BRANCH

if(exist('lambda_LIN')==1)
    disp('STABILITY BRANCH ALREADY COMPUTED')
else
    disp('COMPUTING STABILITY BRANCH')

% LOOP OVER RE FOR BASEFLOW + EIGENMODE
Re_LIN = [40 : 2: 100];
baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-.03+.72i,'nev',1,'type','D');

Cx_LIN = []; Lx_LIN = [];lambda_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        Cx_LIN = [Cx_LIN,baseflow.Cx];
        Lx_LIN = [Lx_LIN,baseflow.Lx];
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_LIN = [lambda_LIN ev];
    end    
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


%%% CHAPTER 4 : determination of critical reynolds number

if(exist('Rec')==1)
    disp('INSTABILITY THRESHOLD ALREADY COMPUTED');
    baseflow=SF_BaseFlow(baseflow,Rec);
    [ev,em] = SF_Stability(baseflow,'shift',em.lambda,'type','S','nev',1);
else 
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
baseflow=SF_BaseFlow(baseflow,'Re',50);
[ev,em] = SF_Stability(baseflow,'shift',+.75i,'nev',1,'type','D');
[baseflow,em]=SF_FindThreshold(baseflow,em);
Rec = baseflow.Re;  Cxc = baseflow.Cx; 
Lxc=baseflow.Lx;    Omegac=imag(em.lambda);
%[ev,em] = SF_Stability(baseflow,'shift',em.lambda,'type','S','nev',1);
end


wnl = SF_WNL(baseflow);

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = sqrt(real(wnl.Lambda)/real(wnl.nu0+wnl.nu2))*real(sqrt(epsilon2_WNL));
Cy_WNL = 2*abs(em.Cy)/em.AEnergy*A_WNL; 
omega_WNL =Omegac+epsilon2_WNL*imag(wnl.Lambda)-imag(wnl.nu0+wnl.nu2)*A_WNL.^2;
%omega_WNLno2 =Omegac+epsilonRANGE.*(imag(wnl.Lambda)-real(wnl.Lambda)*imag(wnl.nu0)/real(wnl.nu0));
Cx_WNL = wnl.Cx0+wnl.Cxeps*epsilon2_WNL+wnl.Cx20*A_WNL.^2;

figure(20);hold on;
plot(Re_WNL,real(wnl.Lambda)*epsilon2_WNL,'g--');hold on;

figure(21);hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--');hold on;

figure(22);hold on;
plot(Re_WNL,Cx_WNL,'g--');hold on;

figure(24); hold on;
plot(Re_WNL,Cy_WNL,'g--');

figure(25);hold on;
plot(Re_WNL,A_WNL,'g--');




%%% CHAPTER 5 : HARMONIC BALANCE

if(exist('Lx_HB')==1)
    disp('Harmonic balance on the range [Rec , 100] already computed');
else
    disp('Computing Harmonic balance on the range [Rec , 100]');
Re_HB = [Rec 47.5 48 49 50 55 60 65 70 75 80 85 90 95 100];
Cx_HB = [Cxc]; Lx_HB = [Lxc]; omega_HB = [Omegac]; Aenergy_HB = [0]; Cy_HB = [0];

baseflow=SF_BaseFlow(baseflow,47.5);
[ev,em] = SF_Stability(baseflow,'shift',Omegac*i);
[meanflow,mode] = SF_HarmonicBalance(baseflow,em,'sigma',0.,'Re',47.5,'Aguess',0.8);

for Re = Re_HB(2:end)
    [meanflow,mode] = SF_HarmonicBalance(meanflow,mode,'Re',Re);
    Lx_HB = [Lx_HB meanflow.Lx];
    Cx_HB = [Cx_HB meanflow.Cx];
    omega_HB = [omega_HB imag(mode.lambda)];
    Aenergy_HB  = [Aenergy_HB mode.AEnergy];
    Cy_HB = [Cy_HB mode.Cy];
end
   
end


%%% chapter 5b : figures

figure(21);hold off;
plot(Re_LIN,imag(lambda_LIN)/(2*pi),'b+-');hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--');hold on;
plot(Re_HB,omega_HB/(2*pi),'r+-');
plot(Rec,Omegac/2/pi,'ro');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','WNL','HB','Location','northwest');
saveas(gca,'Cylinder_Strouhal_Re_HB',figureformat);

figure(22);hold off;
plot(Re_LIN,Cx_LIN,'b+-');hold on;
plot(Re_WNL,Cx_WNL,'g--');hold on;
plot(Re_HB,Cx_HB,'r+-');
plot(Rec,Cxc,'ro')
xlabel('Re');ylabel('Cx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','WNL','HB','Location','south');
saveas(gca,'Cylinder_Cx_Re_HB',figureformat);

figure(23);hold off;
plot(Re_LIN,Lx_LIN,'b+-');hold on;
plot(Re_HB,Lx_HB,'r+-');
plot(Rec,Lxc,'ro');
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','HB','Location','northwest');
saveas(gca,'Cylinder_Lx_Re_HB',figureformat);

figure(24);hold off;
plot(Re_WNL,2*Cy_WNL,'g--');hold on;
plot(Re_HB,2*real(Cy_HB),'r+-');
%title('Harmonic Balance results');
xlabel('Re');ylabel('Cy')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','HB','Location','south');
saveas(gca,'Cylinder_Cy_Re_SC',figureformat);

figure(25);hold off;
plot(Re_WNL,A_WNL,'g--');hold on;
plot(Re_HB,Aenergy_HB,'r+-');
%title('Harmonic Balance results');
xlabel('Re');ylabel('A')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','HB','Location','south');
saveas(gca,'Cylinder_Energy_Re_SC',figureformat);

pause(0.1);


%%% CHAPTER 6 : SELFCONSISTENT APPROACH WITH RE = 100

if(exist('CySC_tab')==1)
    disp(' SC model for Re=100 : calculation already done');
else
    disp(' COMPUTING SC model for Re=100');
% determination of meanflow/selfconsistentmode for Re = 100

baseflow=SF_BaseFlow(baseflow,100);
[ev,em] = SF_Stability(baseflow,'shift',0.12+0.72i,'nev',1,'type','D');
sigma_SC = [real(em.lambda),0.12:-.0025:.1,.09:-.01:0];

Cy_SC = [0]; Energy_SC = [0];
[meanflow,mode] = SF_HarmonicBalance(baseflow,em,'sigma',0.12,'Lguess',0.0156)
for sigma = sigma_SC(2:end)
    [meanflow,mode] = SF_HarmonicBalance(meanflow,mode,'sigma',sigma)
    Cy_SC = [Cy_SC mode.Cy];
    AEnergy_SC = [Energy_SC mode.AEnergy];
end

end

figure(31);hold on;
plot(sigma_SC,real(Cy_SC),'b-+');
xlabel('sigma');ylabel('Cy');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SC100_CySigma',figureformat);


figure(32);hold on;
plot(AEnergy_SC,sigma_SC,'b-+');
ylabel('$\sigma$','Interpreter','latex');xlabel('A');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SC100_EnergySigma',figureformat);


save('Results_Cylinder.mat');


