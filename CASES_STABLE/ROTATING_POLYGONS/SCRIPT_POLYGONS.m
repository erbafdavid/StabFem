
%%% SAMPLE STABFEM PROGRAM TO STUDY THE STABILITY OF POTENTIAL VORTEX
%
% This script reproduces results from figures 4, 5 and 6 from Mougel et al. (2018)


close all;
run('../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';
verbosity = 10;
%%%%%% CHAPTER 0 : creation of initial mesh 
a=.3;
density=40;
xi = .25;
gamma = 0.;
ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);

%%%% CHAPTER 1 : Eigenvalue computation for m=3
[evm3,emm3] =  SF_Stability(ffmesh,'gamma',gamma,'nev',15,'m',3,'shift',3i);
evm3

%%%% 1b : plots
figure(10);
subplot(2,2,1);
n=1;
plotFF(emm3(n),'phi.im','xlim',[0 1],'ylim',[0 .5]);hold on;
hold on;E=0.05/max(abs(emm3(n).eta));
plot(ffmesh.xsurf+E*emm3(n).eta.*ffmesh.N0r,ffmesh.ysurf+E*emm3(n).eta.*ffmesh.N0z,'r');
title('Mode G0')
hold off;
subplot(2,2,2);
n=3;
plotFF(emm3(n),'phi.im','xlim',[0 1],'ylim',[0 .5]);hold on;
hold on;E=0.05/max(abs(emm3(n).eta));
plot(ffmesh.xsurf+E*emm3(n).eta.*ffmesh.N0r,ffmesh.ysurf+E*emm3(n).eta.*ffmesh.N0z,'r');
title('Mode G1')
hold off;
subplot(2,2,3);
n=2;
plotFF(emm3(n),'phi.im','xlim',[0 1],'ylim',[0 .5]);hold on;
hold on;E=0.05/max(abs(emm3(n).eta));
plot(ffmesh.xsurf+E*emm3(n).eta.*ffmesh.N0r,ffmesh.ysurf+E*emm3(n).eta.*ffmesh.N0z,'r');
title('Mode C0');xlim([.2 1]);ylim([0 .5]);
subplot(2,2,4)
n=4;
plotFF(emm3(n),'phi.im','xlim',[0 1],'ylim',[0 .5]);hold on;
hold on;E=0.05/max(abs(emm3(n).eta));
plot(ffmesh.xsurf+E*emm3(n).eta.*ffmesh.N0r,ffmesh.ysurf+E*emm3(n).eta.*ffmesh.N0z,'r');
title('Mode C1')
hold off;
box on; pos = get(gcf,'Position'); pos(3)=pos(4)*1.5;set(gcf,'Position',pos); % resize aspect ratio
saveas(gca,'FIGURES/POLYGONS_modes',figureformat);

pause(0.1);


figure(20);
title('A few free surface shapes for potential vortex');hold on;

%%% CHAPTER 2a : loop for xi = [.3 , .7] by increasing values
ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a .3 density]);
evm3 =  SF_Stability(ffmesh,'gamma',gamma,'nev',20,'m',3,'shift',3i); % without cont for initiating branches

tabxi = .3:.005:.35;
tabEVm3 = [];
for xi = tabxi
    ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);
    figure(20);plot(ffmesh.xsurf,ffmesh.ysurf); hold on;pause(0.1);
    evm3 =  SF_Stability(ffmesh,'gamma',gamma,'nev',20,'m',3,'sort','cont','shift',3i);
    tabEVm3 = [tabEVm3 evm3];    
end

% PLOTS
figure(22);hold on;
for num=1:8
    plot(tabxi,imag(tabEVm3(num,:)),'bo-');
end
figure(23);hold on;
for num=1:8
    plot(tabxi,real(tabEVm3(num,:)),'bo-');
end

%%% CHAPTER 2b : loop for xi = [.3 , .7] by increasing values

tabxi = .35:.025:.7;
tabEVm3 = [];
for xi = tabxi
    ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);
    figure(20);plot(ffmesh.xsurf,ffmesh.ysurf); hold on;pause(0.1);
    evm3 =  SF_Stability(ffmesh,'gamma',gamma,'nev',20,'m',3,'sort','cont','shift',3i);
    tabEVm3 = [tabEVm3 evm3];    
end

% PLOTS
figure(22);hold on;
for num=1:8
    plot(tabxi,imag(tabEVm3(num,:)),'bo-');
end
figure(23);hold on;
for num=1:8
    plot(tabxi,real(tabEVm3(num,:)),'bo-');
end


%%% CHAPTER 2c : loop for xi = [.3 , .1] by decreasing values
ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a .3 density]);
evm3 =  SF_Stability(ffmesh,'gamma',gamma,'nev',20,'m',3,'shift',3i); % without cont for initiating branches

tabxi = .3:-.001:.1;
tabEVm3 = [];
for xi = tabxi
    ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);
    figure(20);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm3 =  SF_Stability(ffmesh,'gamma',gamma,'nev',20,'m',3,'sort','cont','shift',3i);
    tabEVm3 = [tabEVm3 evm3];    
end

% PLOTS
figure(22);hold on;
for num=1:8
    plot(tabxi,imag(tabEVm3(num,:)),'bo-');
end
title('\omega_r(\xi) for H/R = .3 and m=3');
xlabel('\xi');ylabel('\omega_r');
ylim([0 5]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/POLYGONS_omega',figureformat);

figure(23);hold on;
for num=1:8
    plot(tabxi,real(tabEVm3(num,:)),'bo-');
end
title('\omega_i(\xi) for H/R = .3 and m=3');
xlabel('\xi');ylabel('\omega_r');
ylim([0  .1]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/POLYGONS_sigma',figureformat);