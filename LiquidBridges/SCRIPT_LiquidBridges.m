close all;
run('../SOURCES_MATLAB/SF_Start.m');

%%%%%% CHAPTER 0 : creation of initial mesh for cylindrical bridge, L=4

L = 4;
density=45;
%bf=SF_Init('MeshInit_Bridge.edp',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]);


Vol0 = ffmesh.Vol; 
figure(1);hold off;
plot(ffmesh.xsurf,ffmesh.ysurf); hold on;

%%%% CHAPTER 1 : Eigenvalue computation for m=0 and m=1
[evm0,emm0] =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA')
[evm1,emm1] =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA')


%%% PLOT RESULTS
figure(2);
plot(imag(evm0),real(evm0),'ro',imag(evm1),real(evm1),'bo');
title('Cylindrical bridge, L= 4 : spectra for m=0 (red) and m=1 (blue)');
xlabel('\omega_r');ylabel('\omega_i');


figure(3); hold off;
plot(ffmesh.S0,emm0(3).eta);hold on;
plot(ffmesh.S0,emm0(5).eta);
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
plot(ffmesh.S0,emm1(1).eta);
plot(ffmesh.S0,emm1(3).eta);
% on the other hand for m=1 the first modes are regular
title('Cylindrical bridge, L= 4 : structure of the four simplest modes');
legend('m=0,a','m=0,s','m=1,s','m=1,a');


figure(4);plotFF(emm0(3),'phi.im');title('Mode m=0,a');
figure(5);plotFF(emm0(5),'phi.im');title('Mode m=0,s');
figure(6);plotFF(emm1(1),'phi.im');title('Mode m=1,s');
figure(7);plotFF(emm1(3),'phi.im');title('Mode m=1,a');


pause(0.1);

%%%%% CHAPTER 2 : 
% Loop over P0 ; construction of equilibrium shape and stability calculations


% CHAPTER 2a : First loop in the interval [0.85,1] (decreasing values)
L = 4;
density=45;
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)

tabP = 1:-.005:0.85;
tabV = [];
tabEVm0 = []; tabEVm1=[]; 
for P = tabP
    ffmesh = SF_Mesh_Deform(ffmesh,'P',P)
    tabV = [tabV ffmesh.Vol];
    figure(1);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm0 =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA');
    evm1 =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA');
    tabEVm0 = [tabEVm0 evm0];
    tabEVm1 = [tabEVm1 evm1];
    
end

% PLOTS
figure(1);
title('A few equilibrium shapes for liquid bridges');

figure(10);
plot(tabP,tabV,'ro-');
title('P/V relationship for liquid bridge')
xlabel('P');
ylabel('V');

figure(11);hold on;
for num=1:10
    plot(tabP,imag(tabEVm0(num,:)),'ro-',tabP,imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('P');ylabel('\omega_r');
ylim([0 3]);

figure(12);hold on;
for num=1:10
    plot(tabP,real(tabEVm0(num,:)),'ro-',tabP,real(tabEVm1(num,:)),'bo-');
end
title('amplification rates of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('P');ylabel('\omega_i');


%%% CHAPTER 2b : loop for P = [1 - 1.2] by increasing values
L = 4;
density=45;
ffmesh=SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)

tabP = 1:.005:1.2;
tabV = [];
tabEVm0 = []; tabEVm1=[]; 
for P = tabP
    ffmesh = SF_Mesh_Deform(ffmesh,'P',P);
    tabV = [tabV ffmesh.Vol];
    figure(1);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm0 =  SF_Stability(bf,'nev',10,'m',0,'sort','SIA');
    evm1 =  SF_Stability(bf,'nev',10,'m',1,'sort','SIA');
    tabEVm0 = [tabEVm0 evm0];
    tabEVm1 = [tabEVm1 evm1];
    
end

% PLOTS
figure(1);
title('A few equilibrium shapes for liquid bridges');

figure(10);hold on;
plot(tabP,tabV,'ro-');
title('P/V relationship for liquid bridge')
xlabel('P');
ylabel('V');

figure(11);hold on;
for num=1:10
    plot(tabP,imag(tabEVm0(num,:)),'ro-',tabP,imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('P');ylabel('\omega_r');
ylim([0 3]);

figure(12);hold on;
for num=1:10
    plot(tabP,real(tabEVm0(num,:)),'ro-',tabP,real(tabEVm1(num,:)),'bo-');
end
title('amplification rates of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('P');ylabel('\omega_i');

