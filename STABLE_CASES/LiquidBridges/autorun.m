function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the case EXAMPLE_Lshape
%
% USAGE : 
% autorun(0) -> automatic check
% autorun(1) -> produces the figures used for the manual

close all;
run('../../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';verbosity=0;
value = 0;


if(nargin==0) 
    isfigures=0; verbosity=0;
end;
%%

%% CHAPTER 0 : creation of initial mesh for cylindrical bridge, L=4

L = 4;
density=20;
 %creation of an initial mesh (with volume corresponding to coalescence of two spherical caps) 
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]);
V = pi*L/2*(1+L^2/12);
gamma = 1;
rhog = 0;
ffmesh = SF_Mesh_Deform(ffmesh,'V',V,'typestart','pined','typeend','pined','gamma',gamma,'rhog',rhog);


disp('##### autorun test 1 :  deforming the mesh with prescrived volume')
P0 = ffmesh.P0;
P0_REF = 0.9699;
error1 = abs(P0/P0_REF-1)
if(error1>5e-3) 
    value = value+1 
end


if(isfigures)
figure(1);hold off;
plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
end

%% CHAPTER 1 : Eigenvalue computation for m=0 and m=1 FOR A CYLINDRICAL BRIDGE
[evm0,emm0] =  SF_Stability(ffmesh,'nev',16,'m',0,'sort','SIA');
[evm1,emm1] =  SF_Stability(ffmesh,'nev',16,'m',1,'sort','SIA');


ev_m0a = evm0(4)
ev_m0s = evm0(6)
ev_m1s = evm1(2)
ev_m1a = evm1(4)

% previously computed reference values
ev_m0a_REF =   0.0000 + 0.8158i
ev_m0s_REF =   0.0000 + 2.2418i
ev_m1s_REF =   0.0000 + 0.7490i
ev_m1a_REF =   0.0000 + 1.7644i



disp('##### autorun test 2 :  eigenvalues of the four simplest modes (m=0 and m=1)')

error2 = abs(ev_m0a/ev_m0a_REF-1)+abs(ev_m0s/ev_m0s_REF-1)+abs(ev_m1s/ev_m1s_REF-1)+abs(ev_m1a/ev_m1a_REF-1)
if(error2>5e-3) 
    value = value+1 
end


if(isfigures)
%% PLOT RESULTS
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
E=0.15;

subplot(1,4,1);
plotFF(emm0(3),'phi.im','title',{'Mode m=0,a',['\omega_r = ',num2str(-imag(evm0(3)))] } );hold on;
plotFF_ETA(emm0(3),'Amp',E,'style','r');hold off;

subplot(1,4,2);
plotFF(emm0(5),'ur.im','title',{'Mode m=0,s',['\omega_r = ',num2str(-imag(evm0(5)))] } );hold on;
plotFF_ETA(emm0(5),'Amp',E,'style','r');hold off;

subplot(1,4,3);
plotFF(emm1(1),'phi.im','title',{'Mode m=1,s',['\omega_r = ',num2str(-imag(evm1(1)))] } );hold on;
plotFF_ETA(emm1(1),'Amp',E,'style','r');hold off;

subplot(1,4,4);
plotFF(emm1(3),'phi.im','title',{'Mode m=1,a',['\omega_r = ',num2str(-imag(evm1(3)))] } );hold on;
plotFF_ETA(emm1(3),'Amp',E,'style','r');hold off;

pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
%set(gca,'FontSize', 14);
saveas(gcf,'FIGURES/Bridges_NV_Eigenmodes_phi_cyl_L3_5',figureformat);
pause(1);


figure(5); hold on;
E=0.15;
h1 = plotFF_ETA(emm0(3),'Amp',E,'style','b','symmetry','YS');hold on;
h2 = plotFF_ETA(emm0(5),'Amp',E,'style','r','symmetry','YS');hold on;
h3 = plotFF_ETA(emm1(1),'Amp',E,'style','g','symmetry','YA');hold on;
h4 = plotFF_ETA(emm1(3),'Amp',E,'style','c','symmetry','YA');hold on;
h = [h1; h2; h3; h4];

% draw mean shape, end limits and axis
plotFF_ETA(emm1(3),'Amp',0,'style','k','symmetry','YA');hold on;
plot([ffmesh.xsurf(1), -ffmesh.xsurf(1)],[ffmesh.ysurf(1), ffmesh.ysurf(1)],'k','LineWidth',3);
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[ffmesh.ysurf(end), ffmesh.ysurf(end)],'k','LineWidth',3);
plot([0,0],[ffmesh.ysurf(1), ffmesh.ysurf(end)],'k:');

legend(h([1 3 5 7]),'m=0,a','m=0,s','m=1,s','m=1,a');
box on; pos = get(gcf,'Position'); pos(3)=pos(4)*.8;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 12);
saveas(gcf,'FIGURES/Bridges_NV_Eigenmodes_eta_cyl_L3_5',figureformat);
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
pause(1);

end

% test 3 : stretching the bubble and assuming the volume of two touching
% spherical caps


disp('##### autorun test 3 : equilibrium shape with volume corresponding to two touching spherical caps (involving stretching)')

    L = 3.5;
    ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]);
    V = pi*L/2*(1+L^2/12);
    ffmesh = SF_Mesh_Deform(ffmesh,'V',V);
    
    L = 4;
    ffmesh = SF_MeshStretch(ffmesh,1,L/ffmesh.L);
    
    V = pi*L/2*(1+L^2/12);
    ffmesh = SF_Mesh_Deform(ffmesh,'V',V);
    P0REF = 0.969944;
    
    error3 = abs(ffmesh.P0/P0REF-1);
    
if(error3>5e-3) 
    value = value+1 
end




%%
if(isfigures>1)
 %CHAPTER 2 : Construction of equilibrium shape and stability
%%%%% calculations for a family of bridge shapes with L=4 and variable volume and pressure

% CHAPTER 2a : First loop in the interval [0.85,1] (decreasing values)
L = 4;
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)

tabP = 1:-.005:0.85;
tabV = [];
tabEVm0 = []; tabEVm1=[]; 
for P = tabP
    ffmesh = SF_Mesh_Deform(ffmesh,'P',P);
    tabV = [tabV ffmesh.Vol];
    figure(20);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(1);
    evm0 =  SF_Stability(ffmesh,'nev',16,'m',0,'sort','SIA');
    evm1 =  SF_Stability(ffmesh,'nev',16,'m',1,'sort','SIA');
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
for num=1:8
    plot(tabV/(pi*L),imag(tabEVm0(num,:)),'ro-',tabV/(pi*L),imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('V*');ylabel('\omega_r');
ylim([0 3]);


figure(23);hold on;
for num=1:8
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
    pause(1);
    evm0 =  SF_Stability(ffmesh,'nev',16,'m',0,'sort','SIA');
    evm1 =  SF_Stability(ffmesh,'nev',16,'m',1,'sort','SIA');
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
for num=1:8
    plot(tabV/(pi*L),imag(tabEVm0(num,:)),'ro-',tabV/(pi*L),imag(tabEVm1(num,:)),'bo-');
end
title('frequencies of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('V*');ylabel('\omega_r');
ylim([0 3]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_omega',figureformat);

figure(23);hold on;
for num=1:8
    plot(tabV/(pi*L),real(tabEVm0(num,:)),'ro-',tabV/(pi*L),real(tabEVm1(num,:)),'bo-');
end
title('amplification rates of m=0 (red) and m=1 (blue) modes vs. P');
xlabel('V*');ylabel('\omega_i');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_sigma',figureformat);

end % chapter 2








%%
disp('##### autorun test 3 :  eigenvalues in the VISCOUS case')


L = 4;
density=10;
 %creation of an initial mesh (with volume corresponding to coalescence of two spherical caps) 
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]);
V = pi*L/2*(1+L^2/12);
gamma = 1;
rhog = 0;
ffmesh = SF_Mesh_Deform(ffmesh,'V',V,'typestart','pined','typeend','pined','gamma',gamma,'rhog',rhog);
nu = 1e-2;

[evViscm1,emViscm1] =  SF_Stability(ffmesh,'nu',nu,'gamma',1,'nev',10,'m',1,'shift',3.45i);
[evViscm0,emViscm0] =  SF_Stability(ffmesh,'nu',nu,'gamma',1,'nev',10,'m',0,'shift',3.45i);

evViscm0
evViscm1

evm0REF =  [ -0.1101 + 4.0796i  -0.0491 + 2.2391i  -0.1967 + 6.2051i  -0.0120 + 0.8156i];
evm1REF =  [   -0.0818 + 3.0672i  -0.1436 + 4.7451i -0.0380 + 1.7478i -0.2283 + 6.7509i -0.0087 + 0.7452i];

error3=0
error3 = abs(evViscm0(1)/evm0REF(1)-1)+abs(evViscm0(1)/evm0REF(1)-1)+ abs(evViscm1(3)/evm1REF(3)-1)+abs(evViscm1(4)/evm1REF(4)-1)
if(error3>5e-3) 
    value = value+1 
end

if(isfigures>0)
figure(10);
E=0.2;

subplot(1,4,1);
plotFF(emViscm0(4),'ur1.im','title',{'Mode m=0,a',['\omega_r = ',num2str(imag(evViscm0(4))),', \omega_i = ',num2str(real(evViscm0(4))) ]} );hold on;
plotFF_ETA(emViscm0(4),'Amp',E,'style','r');hold off;

subplot(1,4,2);
plotFF(emViscm0(2),'ur1.im','title',{'Mode m=0,s',['\omega_r = ',num2str(imag(evViscm0(2))),', \omega_i = ',num2str(real(evViscm0(2)))]});hold on;
plotFF_ETA(emViscm0(2),'Amp',E,'style','r');hold off;

subplot(1,4,3);
plotFF(emViscm1(5),'ur1.im','title',{'Mode m=1,s',['\omega_r = ',num2str(imag(evViscm1(5))),', \omega_i = ',num2str(real(evViscm1(5))) ] });
hold on;
plotFF_ETA(emViscm1(5),'Amp',E,'style','r');hold off;

subplot(1,4,4);
plotFF(emViscm1(3),'ur1.im','title',{'Mode m=1,a',['\omega_r = ',num2str(imag(evViscm1(3))),', \omega_i = ', num2str(real(evViscm1(3))) ] } );
hold on;
plotFF_ETA(emViscm1(3),'Amp',E,'style','r');hold off;

pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
%set(gca,'FontSize', 14);
saveas(gcf,'FIGURES/Bridges_Viscous_Oh1em2_Eigenmodes_phi_cyl_L3_5',figureformat);

end

end
