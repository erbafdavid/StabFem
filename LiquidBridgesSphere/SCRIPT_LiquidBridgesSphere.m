
%% %%%% CLEAR WORKSPACE AND SET FOLDER AND DATA

% clear workspace;
% clear all;
% close all;

run('../SOURCES_MATLAB/SF_Start.m');

%% %%%% CHAPTER 0 : creation of initial mesh for cylindrical bridge, L=4

% Definition domain length, sphere, the radius of the jet is equal to 1

n=6.0;
kmax=1/sqrt(2);
L=2*pi*n/(kmax);

rsph=0.0; % radius sphere
density=10; % mesh density

% Problem Initialisation

bf=SF_Init('MeshInit_BridgeSphere.edp',[0 L rsph density]); %% creation of an initial mesh (cylindrical liquid bridge)
Vol0 = bf.mesh.Vol;
Area0 = bf.mesh.Area;

% Mesh plot

figure(1);hold off;
plot(bf.mesh.xsurf,bf.mesh.ysurf); hold on;

%% %% CHAPTER 1 : Eigenvalue computation for m=0 (and m=1)
% WARNING: Frequency: omega_r=imag(evm0), Amplification rate: omega_i=real(evm0)

[evm0,emm0] =  SF_Stability(bf,'nev',10,'m',0,'sort','LR')

%% %% RESULTS PLOTS
figure(2);
plot(imag(evm0),real(evm0),'ro');
title('Eigen value');
xlabel('\omega_r');ylabel('\omega_i');


figure(3); %hold off;
plot(bf.mesh.S0/L,emm0(1).eta);hold on;
plot(bf.mesh.S0/L,emm0(2).eta);hold on;
plot(bf.mesh.S0/L,emm0(3).eta);hold on;
plot(bf.mesh.S0/L,emm0(4).eta);hold on;
plot(bf.mesh.S0/L,emm0(5).eta);hold on;
plot(bf.mesh.S0/L,emm0(6).eta);hold on;
plot(bf.mesh.S0/L,emm0(7).eta);hold on;
plot(bf.mesh.S0/L,emm0(8).eta);hold on;
plot(bf.mesh.S0/L,emm0(9).eta);hold on;
plot(bf.mesh.S0/L,emm0(10).eta);hold on;
title('Structure of the computed modes');

legend('m=0,1','m=0,2','m=0,3','m=0,4','m=0,5','m=0,6','m=0,7','m=0,8','m=0,9','m=0,10');

figure(4);
% dispersion relation comparison
plot(kmax/(2*n),abs(real(evm0)),'^'); hold on
% theoretical dispersion relation approximation of long-wavelength
kth=0.0:0.01:1
gamma=1;
rho=1;
omegath=sqrt(gamma/(2*rho)*(kth.^2-kth.^4));
plot(kth,omegath,'-k'); hold on

figure(5);
plotFF(emm0(1),'phi.im');title('Mode m=0,1'); hold on
plotFF(emm0(2),'phi.im');title('Mode m=0,2');
plotFF(emm0(3),'phi.im');title('Mode m=0,3');
plotFF(emm0(4),'phi.im');title('Mode m=0,4');
plotFF(emm0(5),'phi.im');title('Mode m=0,5');
plotFF(emm0(6),'phi.im');title('Mode m=0,6');
plotFF(emm0(7),'phi.im');title('Mode m=0,7');
plotFF(emm0(8),'phi.im');title('Mode m=0,8');
plotFF(emm0(9),'phi.im');title('Mode m=0,9');
plotFF(emm0(10),'phi.im');title('Mode m=0,10');


%
% %%%%% CHAPTER 2 : 
% % Loop over P0 ; construction of equilibrium shape and stability calculations
% 
% 
% % CHAPTER 2a : First loop in the interval [0.85,1] (decreasing values)
% L = 4;
% density=45;
% bf=SF_Init('MeshInit_Sphere.edp',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)
% 
% tabP = 1:-.005:0.85;
% tabV = [];
% tabEVm0 = []; tabEVm1=[]; 
% for P = tabP
%     bf = SF_BaseFlow_FreeSurface(bf,'P',P);
%     tabV = [tabV bf.mesh.Vol];
%     figure(1);
%     plot(bf.mesh.xsurf,bf.mesh.ysurf); hold on;
%     pause(0.1);
%     evm0 =  SF_Stability(bf,'nev',10,'m',0,'sort','SIA');
%     evm1 =  SF_Stability(bf,'nev',10,'m',1,'sort','SIA');
%     tabEVm0 = [tabEVm0 evm0];
%     tabEVm1 = [tabEVm1 evm1];
%     
% end
% 
% % PLOTS
% figure(1);
% title('A few equilibrium shapes for liquid bridges');
% 
% figure(10);
% plot(tabP,tabV,'ro-');
% title('P/V relationship for liquid bridge')
% xlabel('P');
% ylabel('V');
% 
% figure(11);hold on;
% for num=1:10
%     plot(tabP,imag(tabEVm0(num,:)),'ro-',tabP,imag(tabEVm1(num,:)),'bo-');
% end
% title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
% xlabel('P');ylabel('\omega_r');
% ylim([0 3]);
% 
% figure(12);hold on;
% for num=1:10
%     plot(tabP,real(tabEVm0(num,:)),'ro-',tabP,real(tabEVm1(num,:)),'bo-');
% end
% title('amplification rates of m=0 (red) and m=1 (blue) modes vs. P');
% xlabel('P');ylabel('\omega_i');
% 
% 
% %%% CHAPTER 2b : loop for P = [1 - 1.2] by increasing values
% L = 4;
% density=45;
% bf=SF_Init('MeshInit_Bridge.edp',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)
% 
% tabP = 1:.005:1.2;
% tabV = [];
% tabEVm0 = []; tabEVm1=[]; 
% for P = tabP
%     bf = SF_BaseFlow_FreeSurface(bf,'P',P);
%     tabV = [tabV bf.mesh.Vol];
%     figure(1);
%     plot(bf.mesh.xsurf,bf.mesh.ysurf); hold on;
%     pause(0.1);
%     evm0 =  SF_Stability(bf,'nev',10,'m',0,'sort','SIA');
%     evm1 =  SF_Stability(bf,'nev',10,'m',1,'sort','SIA');
%     tabEVm0 = [tabEVm0 evm0];
%     tabEVm1 = [tabEVm1 evm1];
%     
% end
% 
% % PLOTS
% figure(1);
% title('A few equilibrium shapes for liquid bridges');
% 
% figure(10);hold on;
% plot(tabP,tabV,'ro-');
% title('P/V relationship for liquid bridge')
% xlabel('P');
% ylabel('V');
% 
% figure(11);hold on;
% for num=1:10
%     plot(tabP,imag(tabEVm0(num,:)),'ro-',tabP,imag(tabEVm1(num,:)),'bo-');
% end
% title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
% xlabel('P');ylabel('\omega_r');
% ylim([0 3]);
% 
% figure(12);hold on;
% for num=1:10
%     plot(tabP,real(tabEVm0(num,:)),'ro-',tabP,real(tabEVm1(num,:)),'bo-');
% end
% title('amplification rates of m=0 (red) and m=1 (blue) modes vs. P');
% xlabel('P');ylabel('\omega_i');

