%  Instability of the wake of a cylinder with STABFEM  
%
%  this script demonstrates the way to perform HARMONIC BALANCE
%  for the wake of a cylinder in the range Re = [46.7 - 200].


%% ##### CHAPTER 1 : COMPUTING THE MESH WITH ADAPTMESH PROCEDURE
run('../../SOURCES_MATLAB/SF_Start.m');verbosity=10;
figureformat='png'; AspectRatio = 0.56; % for figures

type = 'S';
bf = CYLINDER_MESHGENERATION(type); 
    % here use 'S' for mesh M2 (converged results for all quantities except for A_E , but much faster
    % or 'D' for mesh M4 (converged results for all quantities, but much
    % slower)




%%  CHAPTER 2 : determining instability threshold


disp('COMPUTING INSTABILITY THRESHOLD');
bf=SF_BaseFlow(bf,'Re',50);
[ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','S');
[bf,em]=SF_FindThreshold(bf,em);
Rec = bf.Re;  Fxc = bf.Fx; 
Lxc=bf.Lx;    Omegac=imag(em.lambda);


%% Chapter 3 : solve WNL model and uses it to generate a guess for Res (just above the threshold)
Res = 47;
[ev,em] = SF_Stability(bf,'shift',ev,'nev',1,'type','S'); % type S = direct+adjoint (adjoint is needed for WNL)
[wnl,meanflow,mode,mode2] = SF_WNL(bf,em,'Retest',Res);


%% CHAPTER 5 : SELF CONSISTENT (or HB1), INITIATED BY LINEAR RESULTS WITH A GUESS
%             (alternative to the method using the WNL as a guess)
%
% HERE the initial guess is for Re=47 (slightly above the instability threshold)
% The initialisation is done with the linear eigmode
% with a "small" amplitude (measured by lift force), namely Fy=0.006 .



disp('HB1 model (or SC model) on the range [Rec , 200]');
Re_HB = [Rec 47 47.5 48 49 50 52.5 55 60 65 70 75 80 85 90 95 100 110:10:200 ];
Lx_HB = [Lxc]; Fx_HB = [Fxc]; omega_HB = [Omegac]; Aenergy_HB  = [0]; Fy_HB = [0];

%bf=SF_BaseFlow(bf,'Re',Res);
%[ev,em] = SF_Stability(bf,'shift',Omegac*1i,'nev',1);
%[meanflow,mode] = SF_HB1(bf,em,'sigma',0.,'Re',47.,'Fyguess',0.006); 


for Re = Re_HB(2:end)
    [meanflow,mode] = SF_HB1(meanflow,mode,'Re',Re);
    Lx_HB = [Lx_HB meanflow.Lx];
    Fx_HB = [Fx_HB meanflow.Fx];
    omega_HB = [omega_HB imag(mode.lambda)];
    Aenergy_HB  = [Aenergy_HB mode.AEnergy];
    Fy_HB = [Fy_HB mode.Fy];
end



%% CHAPTER 7 : HARMONIC BALANCE WITH ORDER 2 

[bf,em]=SF_FindThreshold(bf,em);
Rec = bf.Re;  Fxc = bf.Fx; 
Lxc=bf.Lx;    Omegac=imag(em.lambda);
[wnl,meanflow,mode,mode2] = SF_WNL(bf,em,'Retest',Res); % Here to generate a starting point for the next chapter
[meanflow,mode,mode2] = SF_HB2(meanflow,mode,mode2);
Re_HB = [Rec 47 47.5 48 49 50 52.5 55 60 65 70 75 80 85 90 95 100 110:10:200];
Lx_HB2 = [Lxc]; Fx_HB2 = [Fxc]; omega_HB2 = [Omegac]; Aenergy_HB2  = [0]; Fy_HB2 = [0];Fx2_HB2 = [0];

for Re = Re_HB(2:end)
    [meanflow,mode,mode2] = SF_HB2(meanflow,mode,mode2,'Re',Re);
    Lx_HB2 = [Lx_HB2 meanflow.Lx];
    Fx_HB2 = [Fx_HB2 meanflow.Fx];
    omega_HB2 = [omega_HB2 imag(mode.lambda)];
    Aenergy_HB2  = [Aenergy_HB2 sqrt(mode.AEnergy^2+ mode2.AEnergy^2)];
    Fy_HB2 = [Fy_HB2 mode.Fy];
    Fx2_HB2 = [Fx2_HB2 mode2.Fx];
end

save('Results_Cylinder_HB12.mat');
%'Lx_HB','Fx_HB','omega_HB','Aenergy_HB','Fy_HB','Lx_HB2','Fx_HB2','omega_HB2','Aenergy_HB2','Fy_HB2','Fx2_HB2');


%% Drawing figures
%load('Results_Cylinder_HB12.mat');
%load('Cylinder_AllFigures.mat');


figure(21);hold off;
plot(Re_LIN,imag(lambda_LIN)/(2*pi),'b+-');
hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--','LineWidth',2);hold on;
plot(Re_HB,omega_HB/(2*pi),'r+-','LineWidth',2);
plot(Re_HB,omega_HB2/(2*pi),'co-','LineWidth',2);
plot(Rec,Omegac/2/pi,'ro');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','WNL','HB-1','HB-2','Location','northwest');
saveas(gca,'FIGURES/Cylinder_Strouhal_Re_HB2',figureformat);

figure(22);hold off;
%plot(Re_LIN,2*Fx_LIN,'b+-');
hold on;
plot(Re_WNL,Fx_WNL,'g--','LineWidth',2);hold on;
plot(Re_HB,Fx_HB,'r+-','LineWidth',2);
plot(Re_HB,Fx_HB2,'co-','LineWidth',2);
plot(Re_HB,Fx_HB2+abs(Fx2_HB2),'c:','LineWidth',2);
plot(Re_HB,Fx_HB2-abs(Fx2_HB2),'c:','LineWidth',2);
plot(Rec,Fxc,'ro')
xlabel('Re');ylabel('Fx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','WNL','HB-1','HB-2','Location','south');
saveas(gca,'FIGURES/Cylinder_Fx_Re_HB2',figureformat);

figure(23);hold off;
%plot(Re_LIN,Lx_LIN,'b+-');
hold on;
plot(Re_HB,Lx_HB,'r+-','LineWidth',2);
plot(Re_HB,Lx_HB2,'co-','LineWidth',2);
plot(Rec,Lxc,'ro','LineWidth',2);
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','HB-1','HB-2','Location','northwest');
saveas(gca,'FIGURES/Cylinder_Lx_Re_HB2',figureformat);

figure(24);hold off;
plot(Re_WNL,Fy_WNL,'g--','LineWidth',2);
hold on;
plot(Re_HB,real(Fy_HB),'r+-','LineWidth',2);
plot(Re_HB,real(Fy_HB2),'co-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('Fy')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','HB-1','HB-2','Location','south');
saveas(gca,'FIGURES/Cylinder_Fy_Re_HB2',figureformat);

figure(25);hold off;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
hold on;
plot(Re_HB,Aenergy_HB,'r+-','LineWidth',2);
plot(Re_HB,Aenergy_HB2,'co-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('A_E')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('WNL','HB-1','HB-2','Location','south');
saveas(gca,['FIGURES/Cylinder_Energy_Re_HB2_',type],figureformat);

pause(0.1);

