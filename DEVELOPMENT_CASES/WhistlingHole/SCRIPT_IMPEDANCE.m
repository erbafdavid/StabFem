run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
close all;
set(0, 'DefaultLineLineWidth', 2);

Re = 1500;
chi = 1;

%% Chapter 1 : mesh
if(exist('./WORK/BASEFLOWS/BaseFlow_Re1500.ff2m')~=2);
    disp('Creating baseflow/mesh')
    bf = SmartMesh_Hole(chi);
else
    disp('Recovering baseflow/mesh')
    ffmesh = importFFmesh('./WORK/mesh.msh'); bf = importFFdata(ffmesh,'./WORK/BASEFLOWS/BaseFlow_Re1500.ff2m');
    bf = SF_BaseFlow(bf);
end

figure; plotFF(bf,'ux','title','Base Flow');

pause(0.1);

%% chapter 2 : impedances curves for Re= 800, 1200, 1500, 1800

REtab = [800 1200 1500 1800];OmegaRange = [0 : .1  : 8];
for k = 1:length(REtab)
Re = REtab(k);
bf = SF_BaseFlow(bf,'Re',Re);
II = SF_LinearForced(bf,OmegaRange);
%II = SF_Launch('LoopImpedance.edp','Params',OmegaRange,'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);

figure;
subplot(1,2,1); hold on;
plot(II.omega,real(II.Z),'b-',II.omega,-imag(II.Z)./II.omega,'b--');hold on;
plot(II.omega,0*real(II.Z),'k:','LineWidth',1)
xlabel('\omega');ylabel('Z_r, -Z_i/\omega');
title(['Impedance for chi =1, Re = ',num2str(Re)] );
subplot(1,2,2);hold on;
xmin = min([-1 1*floor(min(real(II.Z*1)))]);
xmax = 0;
ymin = 1*floor(min(imag(II.Z*1)));
ymax = max([1 1*ceil(max(imag(II.Z*1)))]);
rectangle('Position',[xmin,ymin,xmax-xmin,ymax-ymin],'LineStyle','-','Edgecolor','none', 'FaceColor',[1 0.9 0. 0.4])
rectangle('Position',[xmin,0,xmax-xmin,ymax],'LineStyle','-','Edgecolor','none', 'FaceColor',[0.9100    0.4100    0.1700 0.5 ])
plot(real(II.Z),imag(II.Z)); title(['Nyquist diagram for chi =1, Re =',num2str(Re)] );
xlabel('Z_r');ylabel('Z_i');ylim([-6 1]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos);
pause(0.1);
saveas(gcf,['Impedance_and_Nyquist_chi1_Re',num2str(Re)],'png');
saveas(gcf,['Impedance_and_Nyquist_chi1_Re',num2str(Re)],'fig');
pause(0.1);
end



%% Chapter 3 : stability

bf = SF_BaseFlow(bf,'Re',1500);
[ev,em] = SF_Stability(bf,'m',0,'shift',-.036-2.050i,'nev',20,'solver','StabAxi_COMPLEX_m0.edp','plotspectrum','yes')
figure;plotFF(em(1),'ux1');

%%
Re_tab = [1500 : 50 : 2000];  
ev_tab_H2 = SF_Stability_LoopRe(bf,Re_tab,0.3-2.23i,'m',0,'solver','StabAxi_COMPLEX_m0_nev1.edp');
ev_tab_H3 = SF_Stability_LoopRe(bf,Re_tab,0.22-4.33i,'m',0,'solver','StabAxi_COMPLEX_m0_nev1.edp');
ev_tab_H1 = SF_Stability_LoopRe(bf,Re_tab,-.04-.562i,'m',0,'solver','StabAxi_COMPLEX_m0_nev1.edp');
figure(20);
plot(Re_tab,real(ev_tab),'r',Re_tab,-imag(ev_tab),'b');
saveas(gcf,['Eigenvalues_chi1_CM'],'png');
pause(0.1);


%% Chapter 4 : eigenvalue prediction based on Impedance


% This loop uses the function Imp2Stab

OmegaS = [1.9 :.05 :2];%initial range ; will be updated
Re_tabI = [1200 : 100:2000];omega0_tabI = [];sigma1_tabI = [];
for Re = Re_tabI
    bf = SF_BaseFlow(bf,'Re',Re);
    res = Imp2Stab(bf,OmegaS);
    omega0_tabI = [ omega0_tabI res.omega0 ];
    sigma1_tabI = [ sigma1_tabI res.sigma1 ]; 
    OmegaS = [res.omega0-.05 :.05 : res.omega0+.05];%update range
    figure(20);hold on;
    plot(Re,res.omega0,'+b',Re,res.sigma1,'r+');
    pause(0.1);
end

figure(20);hold on;
plot(Re_tabI,omega0_tabI,'+b',Re_tabI,sigma1_tabI,'r+');
pause(0.1);
saveas(gcf,['Eigenvalues_chi1_CM'],'png');

%%
load('NOMAPPING/results_nomap')    

figure(120);hold off;
subplot(2,1,1);
plot(Re_Range,real(EVH2),'r--','linewidth',2);hold on;
plot(Re_tab,real(ev_tab),'b-','linewidth',2);
plot(Re_tabI,sigma1_tabI,'g+','linewidth',2);
plot(Re_Range,0*real(EVH2),'k:');ylim([-.2 .4]);xlim([1200  2000]);
xlabel('Re');ylabel('\sigma')
subplot(2,1,2);hold off;
plot(Re_Range,imag(EVH2),'r--',Re_tab,-imag(ev_tab),'b-');hold on;
plot(Re_tabI,omega0_tabI,'g+');hold on;
%plot(Re_Range(real(EVH2)>0),imag(EVH2(real(EVH2)>0)),'r-','linewidth',2);hold on;
%plot(Re_Range(real(EVH3)>0),imag(EVH3(real(EVH3)>0)),'b-','linewidth',2);ylim([0 5]);xlim([1200  2000]);
xlabel('Re');ylabel('\omega')
saveas(gcf,'Eigenvalues_onehole_chi1_sigmaomega','png')

saveas(gcf,'Eigenvalues_onehole_chi1_sigmaomega','fig')



