%%
close all;
run('../../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';
%% CHAPTER 0 : creation of initial mesh for cylindrical bridge, L=4

L = 4;
density=20;
 %creation of an initial mesh (with volume corresponding to coalescence of two spherical caps) 
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]);
V = pi*L/2*(1+L^2/12);
gamma = 1;
rhog = 0;
ffmesh = SF_Mesh_Deform(ffmesh,'V',V,'typestart','pined','typeend','pined','gamma',gamma,'rhog',rhog);

Vol0 = ffmesh.Vol; 
figure(1);hold off;
plot(ffmesh.xsurf,ffmesh.ysurf); hold

%% CHAPTER 1 : Eigenvalue computation for m=0 and m=1 FOR A CYLINDRICAL BRIDGE
[evm0,emm0] =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA');
[evm1,emm1] =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA');

%%% PLOT RESULTS
figure(2);
plot(imag(evm0),real(evm0),'ro',imag(evm1),real(evm1),'bo');
title('Cylindrical bridge, L= 4 : spectra for m=0 (red) and m=1 (blue)');
xlabel('\omega_r');ylabel('\omega_i');

figure(3); hold off;
plot(ffmesh.S0,real(emm0(3).eta));hold on;
plot(ffmesh.S0,real(emm0(5).eta));
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
plot(ffmesh.S0,real(emm1(1).eta));
plot(ffmesh.S0,real(emm1(3).eta));
% on the other hand for m=1 the first modes are regular
title('Cylindrical bridge, L= 4 : structure of the four simplest modes eta(s) ');
legend('m=0,a','m=0,s','m=1,s','m=1,a');


figure(4);
subplot(1,4,1);plotFF(emm0(3),'phi.im','title','Mode m=0,a');
hold on;E=0.15/max(abs(emm0(3).eta));
plot(ffmesh.xsurf+E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'r');hold off;
subplot(1,4,2);plotFF(emm0(5),'phi.im','title','Mode m=0,s');
hold on;E=0.15/max(abs(emm0(5).eta));
plot(ffmesh.xsurf+E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'r');hold off;
subplot(1,4,3);plotFF(emm1(1),'phi.im','title','Mode m=1,s');
E=0.15/max(abs(emm1(1).eta));
hold on;plot(ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'r');
subplot(1,4,4);plotFF(emm1(3),'phi.im','title','Mode m=1,a');
E=0.15/max(abs(emm1(3).eta));
hold on;plot(ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'r');
pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
%set(gca,'FontSize', 14);
saveas(gcf,'FIGURES/Bridges_NV_Eigenmodes_phi_cyl_L3_5',figureformat);
pause;


figure(5); hold on;
E=0.15/max(abs(emm0(3).eta));
plot(ffmesh.xsurf+E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'b');
E=0.15/max(abs(emm0(5).eta));
plot(ffmesh.xsurf+E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'r');
E=0.15/max(abs(emm1(1).eta));
plot(ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'g');
E=0.15/max(abs(emm1(3).eta));
plot(ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'c');
E=0.15/max(abs(emm0(3).eta));
plot(-ffmesh.xsurf-E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'b');
E=0.15/max(abs(emm0(5).eta));
plot(-ffmesh.xsurf-E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'r');
E=0.15/max(abs(emm1(1).eta));
plot(-ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'g');
E=0.15/max(abs(emm1(3).eta));
plot(-ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'c');
% draw mean shape, end limits and axis
plot(ffmesh.xsurf,ffmesh.ysurf,'k');
plot(-ffmesh.xsurf,ffmesh.ysurf,'k');
plot([ffmesh.xsurf(1), -ffmesh.xsurf(1)],[ffmesh.ysurf(1), ffmesh.ysurf(1)],'k','LineWidth',3);
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[ffmesh.ysurf(end), ffmesh.ysurf(end)],'k','LineWidth',3);
plot([0,0],[ffmesh.ysurf(1), ffmesh.ysurf(end)],'k:');
legend('m=0,a','m=0,s','m=1,s','m=1,a');
box on; pos = get(gcf,'Position'); pos(3)=pos(4)*.8;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 12);
saveas(gcf,'FIGURES/Bridges_NV_Eigenmodes_eta_cyl_L3_5',figureformat);
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
%%
pause(0.1);

%%
if(1==1)
 %CHAPTER 2 : Construction of equilibrium shape and stability
%%%%% calculations for a family of bridge shapes with L=4 and variable volume and pressure

% CHAPTER 2a : First loop in the interval [0.85,1] (decreasing values)
L = 4;
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)

tabP = 1:-.005:0.85;
tabV = [];
tabEVm0 = []; tabEVm1=[]; 
for P = tabP
    ffmesh = SF_Mesh_Deform(ffmesh,'P',P)
    tabV = [tabV ffmesh.Vol];
    figure(20);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm0 =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA');
    evm1 =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA');
    tabEVm0 = [tabEVm0 evm0];
    tabEVm1 = [tabEVm1 evm1];
    
end

% PLOTS
figure(20);
title('A few equilibrium shapes for liquid bridges');

figure(21);
plot(tabP,tabV/(pi*L),'ro-');
xlabel('P*');ylabel('V*');
title('P*/V* relationship for liquid bridges with L* = 3.5');

figure(22);hold on;
for num=1:10
    plot(tabV/(pi*L),imag(tabEVm0(num,:)),'ro-',tabV/(pi*L),imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('V*');ylabel('\omega_r');
ylim([0 3]);


figure(23);hold on;
for num=1:10
    plot(tabV/(pi*L),real(tabEVm0(num,:)),'ro-',tabV/(pi*L),real(tabEVm1(num,:)),'bo-');
end
title('amplification rates of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('V*');ylabel('\omega_i');



%%% CHAPTER 2b : loop for P = [1 - 1.2] by increasing values
L = 4;
ffmesh=SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)

tabP = 1:.005:1.2;
tabV = [];
tabEVm0 = []; tabEVm1=[]; 
for P = tabP
    ffmesh = SF_Mesh_Deform(ffmesh,'P',P);
    tabV = [tabV ffmesh.Vol];
    figure(20);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm0 =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA');
    evm1 =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA');
    tabEVm0 = [tabEVm0 evm0];
    tabEVm1 = [tabEVm1 evm1];
    
end

% PLOTS
figure(20);
title('A few equilibrium shapes for liquid bridges');

figure(21);hold on;
plot(tabP,tabV/(pi*L),'ro-');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_PV',figureformat);


figure(22);hold on;
for num=1:10
    plot(tabV/(pi*L),imag(tabEVm0(num,:)),'ro-',tabV/(pi*L),imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('V*');ylabel('\omega_r');
ylim([0 3]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_omega',figureformat);

figure(23);hold on;
for num=1:10
    plot(tabV/(pi*L),real(tabEVm0(num,:)),'ro-',tabV/(pi*L),real(tabEVm1(num,:)),'bo-');
end
title('amplification rates of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('V*');ylabel('\omega_i');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_sigma',figureformat);

end % chapter 2









%%%%% CHAPTER 3 : Construction of equilibrium shapes WITH VOLUME
%%%%% CORRESPONDING TO THAT OF TOUCHING SPHERES (Chireux et al.)
%%%%% 

% CHAPTER 3a : First loop in the interval [3.5,7] (increasing values)
L = 3.5;
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)

tabL = 3.5:.1:7; Lans= tabL(1);
tabV = [];
tabP = [];
tabEVm0 = []; tabEVm1=[]; 
for L = tabL
    ffmesh = SF_MeshStretch(ffmesh,1,L/Lans);
    V = pi*L/2*(1+L^2/12);
    ffmesh = SF_Mesh_Deform(ffmesh,'V',V)
    tabV = [tabV ffmesh.Vol]; tabP = [tabP ffmesh.P0];
    figure(30);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm0 =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA');
    evm1 =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA');
    tabEVm0 = [tabEVm0 evm0];
    tabEVm1 = [tabEVm1 evm1];
    Lans = L;
end

% PLOTS
figure(30);
title('A few equilibrium shapes for liquid bridges');

figure(32);hold on;
for num=1:10
    plot(tabL,imag(tabEVm0(num,:)),'ro-',tabL,imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. L');
xlabel('L');ylabel('\omega_r');


figure(33);hold on;
for num=1:10
    plot(tabL,imag(tabEVm0(num,:)).*tabL.^1.5,'ro-',tabL,imag(tabEVm1(num,:)).*tabL.^1.5,'bo-');
end
title('rescaled frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('L');ylabel('\omega_r/\omega_L');
ylim([0 22]);

% CHAPTER 3ab : First loop in the interval [3.5,2] (decreasing values)
L = 3.5;
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)

tabL = 3.5:-.1:2; Lans= tabL(1);
tabV = [];
tabP = [];
tabEVm0 = []; tabEVm1=[]; 
for L = tabL
    ffmesh = SF_MeshStretch(ffmesh,1,L/Lans);
    V = pi*L/2*(1+L^2/12);
    ffmesh = SF_Mesh_Deform(ffmesh,'V',V)
    tabV = [tabV ffmesh.Vol]; tabP = [tabP ffmesh.P0];
    figure(30);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm0 =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA');
    evm1 =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA');
    tabEVm0 = [tabEVm0 evm0];
    tabEVm1 = [tabEVm1 evm1];
    Lans = L;
end

% PLOTS
figure(30);
title('A few equilibrium shapes for liquid bridges');

figure(32);hold on;
for num=1:10
    plot(tabL,imag(tabEVm0(num,:)),'ro-',tabL,imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. L');
xlabel('L');ylabel('\omega_r');
ylim([0 6]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_coal_omega',figureformat);

figure(33);hold on;
for num=1:10
    plot(tabL,imag(tabEVm0(num,:)).*tabL.^1.5,'ro-',tabL,imag(tabEVm1(num,:)).*tabL.^1.5,'bo-');
end
title('rescaled frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('L');ylabel('\omega_r/\omega_L');
ylim([0 22]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_coal_omegaL',figureformat);


