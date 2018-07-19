
%  Instability of the wake of a cylinder with STABFEM  
%
%  this script demonstrates the way to perform HARMONIC BALANCE
%  for the wake of a cylinder in the range Re = [46.7 - 200].


%% ##### CHAPTER 1 : COMPUTING THE MESH WITH ADAPTMESH PROCEDURE
run('../../SOURCES_MATLAB/SF_Start.m');verbosity=10;
figureformat='png'; AspectRatio = 0.56; % for figures
mkdir('RESULTS');

type = 'S';
if(exist('WORK/mesh.msh')==1)
    bf = SmartMesh_Cylinder(type); 
    % here use 'S' for mesh M2 (converged results for all quantities except for A_E , but much faster
    % or 'D' for mesh M4 (converged results for all quantities, but much
    % slower)
else
    ffmesh = importFFmesh('WORK/mesh.msh');
    bf = importFFdata(ffmesh,'WORK/BaseFlow.ff2m');
end


%% chapter 2 : linear / BF results
Re_TAB = [40 :10 : 200];

if(exist('RESULTS/LINresS.mat')==0)
    LINres = Linear_LoopRe(bf,0.75i-.1,Re_TAB);
    save('RESULTS/LINresS.mat','LINres');
else
    load('RESULTS/LINresS.mat');
end



%%  CHAPTER 3 : determining instability threshold

disp('COMPUTING INSTABILITY THRESHOLD');
bf=SF_BaseFlow(bf,'Re',50);
[ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','S');
[bfT,emT]=SF_FindThreshold(bf,em);
Rec = bfT.Re;

%% CHAPTER 4 : HB1 Loop over Re

Re_TAB = [Rec 47 47.5 48 49 50 52.5 55 60 65 70 75 80 85 90 95 100 110:10:200];

if(exist('RESULTS/HBresS.mat')==0)
    HBres = HB1_LoopRe(bfT,emT,Re_TAB) ; 
    save('RESULTS/HBresS.mat','HBres');
else
    load('RESULTS/HBresS.mat');
end

%% CHAPTER 5 : HB2 Loop over Re

if(exist('RESULTS/HB2res.mat')==0)
    HB2res = HB2_LoopRe(bfT,emT,Re_TAB) ; 
    save('RESULTS/HB2resS.mat','HB2res');
else
    load('RESULTS/HB2resS.mat');
end


%% Chapter 6 : figures;

figure(21);hold off;
plot(LINres.Re,imag(LINres.lambda)/(2*pi),'b+-');
hold on;

plot(HBres.Re,HBres.omega/(2*pi),'r+-','LineWidth',2);
plot(HB2res.Re,HBres.omega/(2*pi),'co-','LineWidth',2);
plot(Rec,Omegac/2/pi,'ro');
xlabel('Re');ylabel('St');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Linear','HB-1','HB-2','Location','northwest');
saveas(gca,'FIGURES/Cylinder_Strouhal_HBres.Re2',figureformat);

figure(22);hold off;
plot(LINres.Re,LINres.Fx,'b+-');
hold on;
%plot(Re_WNL,Fx_WNL,'g--','LineWidth',2);hold on;
plot(HBres.Re,HBres.Fx0,'r+-','LineWidth',2);
plot(HB2res.Re,HB2res.Fx0,'co-','LineWidth',2);
plot(HB2res.Re,HB2res.Fx0+abs(HB2res.Fx2),'c:','LineWidth',2);
plot(HB2res.Re,HB2res.Fx0-abs(HB2res.Fx2),'c:','LineWidth',2);
plot(Rec,Fxc,'ro')
xlabel('Re');ylabel('Fx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('HB-1','HB-2','Location','south');
saveas(gca,'FIGURES/Cylinder_Fx_HBres.Re2',figureformat);

figure(23);hold off;
plot(LINres.Re,LINres.Lx,'b+-');
hold on;
plot(HBres.Re,HBres.Lx,'r+-','LineWidth',2);
plot(HB2res.Re,HB2res.Lx,'co-','LineWidth',2);
plot(Rec,Lxc,'ro','LineWidth',2);
xlabel('Re');ylabel('Lx');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('BF','HB-1','HB-2','Location','northwest');
saveas(gca,'FIGURES/Cylinder_Lx_HBres.Re2',figureformat);

figure(24);hold off;
%plot(Re_WNL,Fy_WNL,'g--','LineWidth',2);
hold on;
plot(HBres.Re,real(HBres.Fy),'r+-','LineWidth',2);
plot(HB2res.Re,real(HB2res.Fy),'co-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('Fy')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('HB-1','HB-2','Location','south');
saveas(gca,'FIGURES/Cylinder_Fy_HBres.Re2',figureformat);

figure(25);hold off;
%plot(Re_WNL,A_WNL,'g--','LineWidth',2);
hold on;
plot(HBres.Re,HBres.Aenergy,'r+-','LineWidth',2);
plot(HB2res.Re,HB2res.Aenergy,'co-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('A_E')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('HB-1','HB-2','Location','south');
saveas(gca,['FIGURES/Cylinder_Energy_HBres.Re2_',type],figureformat);

pause(0.1);


