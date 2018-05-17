%  Instability of the wake of a cylinder with STABFEM  
%
%  this script demonstrates the main fonctionalities of StabFem for the
%  reference case of the wake of a cylinder.
%  1/ Generation of an adapted mesh 

%  3/ Stability curves St(Re) and sigma(Re) for Re = [40-100]
%  4/ Determination of the instability threshold and Weakly-Nonlinear
%  analysis
%  5/ Harmonic-Balance for Re = REc-100
%  6/ Self-consistent model for Re=100

% CHAPTER 0 : set the global variables needed by the drivers


run('../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
verbosity = 10; % to follow what's going on...

%##### CHAPTER 1 : COMPUTING THE MESH WITH ADAPTMESH PROCEDURE


if(exist('mesh_completed')==0)
disp('generation of a mesh : ')    
bf=SF_Init('Mesh_Cylinder.edp',[-40 80 40]);
bf=SF_BaseFlow(bf,'Re',1);
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_Adapt(bf,'Hmax',5);
disp(' ');







%%% CHAPTER 2 : determining instability threshold

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




%%% CHAPTER 3 : computation of weakly nonlinear expansion

[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S'); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,'Retest',47.); % Here to generate a starting point for the next chapter

%%% PLOTS of WNL predictions

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL = wnl.Fyeps*2*real(sqrt(epsilon2_WNL));
omega_WNL =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL*(epsilon2_WNL>0) ;

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
%plot(Re_LIN,imag(lambda_LIN)/(2*pi),'b+-');
hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--','LineWidth',2);hold on;
plot(Re_HB,omega_HB/(2*pi),'r+-','LineWidth',2);
plot(Rec,Omegac/2/pi,'ro');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','WNL','SCQL','Location','northwest');
saveas(gca,'Cylinder_Strouhal_Re_HB',figureformat);

figure(22);hold off;
%plot(Re_LIN,2*Fx_LIN,'b+-');
hold on;
plot(Re_WNL,2*Fx_WNL,'g--','LineWidth',2);hold on;
plot(Re_HB,2*Fx_HB,'r+-','LineWidth',2);
plot(Rec,Fxc,'ro')
xlabel('Re');ylabel('Cx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','WNL','SCQL','Location','south');
saveas(gca,'Cylinder_Cx_Re_HB',figureformat);

figure(23);hold off;
%plot(Re_LIN,Lx_LIN,'b+-');
hold on;
plot(Re_HB,Lx_HB,'r+-','LineWidth',2);
plot(Rec,Lxc,'ro','LineWidth',2);
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','SCQL','Location','northwest');
saveas(gca,'Cylinder_Lx_Re_HB',figureformat);

figure(24);hold off;
plot(Re_WNL,2*Fy_WNL,'g--','LineWidth',2);
hold on;
plot(Re_HB,2*real(Fy_HB),'r+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('Cy')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','SCQL','Location','south');
saveas(gca,'Cylinder_Cy_Re_SC',figureformat);

figure(25);hold off;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
hold on;
plot(Re_HB,Aenergy_HB,'r+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('A_E')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','HB','Location','south');
saveas(gca,'Cylinder_Energy_Re_SC',figureformat);

pause(0.1);


%%% CHAPTER 6 : SELFCONSISTENT APPROACH WITH RE = 100

if(exist('SC_completed')==1)
    disp(' SC model for Re=100 : calculation already done');
else
    disp(' COMPUTING SC model for Re=100');
% determination of meanflow/selfconsistentmode for Re = 100

bf=SF_BaseFlow(bf,'Re',100);
[ev,em] = SF_Stability(bf,'shift',0.12+0.72i,'nev',1,'type','D');
sigma_SC = [real(em.lambda),0.12:-.01:0];

Fy_SC = [0]; Energy_SC = [0];
[meanflow,mode] = SF_SelfConsistentDirect(bf,em,'sigma',0.12,'Fyguess',0.00728)
for sigma = sigma_SC(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'sigma',sigma)
    Fy_SC = [Fy_SC mode.Fy];
    AEnergy_SC = [AEnergy_SC mode.AEnergy];
end
SC_completed = 1;
end

figure(31);hold on;
plot(sigma_SC,2*real(Fy_SC),'b-+','LineWidth',2);
xlabel('sigma');ylabel('Cy');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SC100_CySigma',figureformat);


figure(32);hold on;
plot(AEnergy_SC,sigma_SC,'b-+','LineWidth',2);
ylabel('$\sigma$','Interpreter','latex');xlabel('A_E');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SC100_EnergySigma',figureformat);

%%%% CHAPTER 7 : HARMONIC BALANCE WITH ORDER 2 (in progress...)


[wnl,meanflow,mode,mode2] = SF_WNL(bf,'Retest',47.5); % Here to generate a starting point for the next chapter
[meanflow,mode,mode2] = SF_HarmonicBalance_Ordre2(meanflow,mode,mode2);


%save('Results_Cylinder.mat');


