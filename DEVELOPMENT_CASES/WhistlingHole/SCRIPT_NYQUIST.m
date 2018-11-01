%%% THIS SCRIPT WILL PRODUCE FIGURE 9 OF THE JFM BY LONGOBARDI ET AL :
%%% Impedances and Nyquist for chi=1, Re=800,1200,1600.

%%% Bonus : at the end of the script is something generating figure 2.

run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
close all;
set(0, 'DefaultLineLineWidth', 2);

Re = 1500;
chi = 1;

%% Chapter 1 : mesh
if(exist('./WORK/MESHES/BaseFlow_adapt6_Re1500.ff2m')~=2);
    disp('Creating baseflow/mesh')
    bf = SmartMesh_Hole(chi);
else
    disp('Recovering baseflow/mesh')
    ffmesh = importFFmesh('./WORK/MESHES/mesh_adapt6_Re1500.msh'); 
    bf = importFFdata(ffmesh,'./WORK/MESHES/BaseFlow_adapt6_Re1500.ff2m');
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
ymin = 1*floor(min(imag(II.Z*1)))+1;
ymax = max([1 1*ceil(max(imag(II.Z*1)))]);
rectangle('Position',[xmin,ymin,xmax-xmin,ymax-ymin],'LineStyle','-','Edgecolor','none', 'FaceColor',[1 0.9 0. 0.4])
rectangle('Position',[xmin,0,xmax-xmin,ymax],'LineStyle','-','Edgecolor','none', 'FaceColor',[0.9100    0.4100    0.1700 0.5 ])
plot(real(II.Z),imag(II.Z)); title(['Nyquist diagram for chi =1, Re =',num2str(Re)] );
xlabel('Z_r');ylabel('Z_i');ylim([-10 2]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos);
pause(0.1);
saveas(gcf,['Impedance_and_Nyquist_chi1_Re',num2str(Re)],'png');
saveas(gcf,['Impedance_and_Nyquist_chi1_Re',num2str(Re)],'fig');
pause(0.1);
end



%% The following has been used for figure 2 of the paper 
% (sketches for the impedance-bases instability criteria)


set(0, 'DefaultLineLineWidth', 2);
set(0,'defaultUicontrolFontSize',14); 
set(0,'defaultAxesFontSize',14);
set(0,'defaultTextFontSize',14);
set(0,'defaultLineMarkerSize',5);


t = 0:.01:2.5;
Z1= -.2+(t-1).^2-.015*t.^5-(.25*t-.05*t.^2)*1i;
figure;hold off;
subplot(2,2,1); hold on;
rectangle('Position',[.55,-.6,1.03,1.7],'LineStyle','--','Edgecolor','k', 'FaceColor',[1 0.9 0. 0.4]);
plot(t,real(Z1),'b-',t,imag(Z1),'b--');hold on;
plot(t,0*real(Z1),'k:','LineWidth',1)
plot(t(55),0*real(Z1(55)),'bo')
plot(t(55),imag(Z1(55)),'bo')
plot(t(161),0*real(Z1(161)),'bo')
plot(t(161),imag(Z1(161)),'bo')
xlabel('\omega');ylabel('Z_r, Z_i');
ylim([-.5 1]);xlim([0 2.5]); box on;
text(-.5,1,'(a)');
text(.6,.09,'\omega_1')
text(1.32,.09,'\omega_2')

subplot(2,2,2);hold on;
xmin = -.5;
xmax = 0;
ymin = -2;
ymax = .5;
rectangle('Position',[xmin,ymin,xmax-xmin,ymax-ymin],'LineStyle','-','Edgecolor','none', 'FaceColor',[1 0.9 0. 0.4])
rectangle('Position',[xmin,0,xmax-xmin,ymax],'LineStyle','-','Edgecolor','none', 'FaceColor',[0.9100    0.4100    0.1700 0.5 ])
plot(real(Z1),imag(Z1),'b');
plot(real(Z1(161)),imag(Z1(161)),'bo')
plot(real(Z1(55)),imag(Z1(55)),'bo')
plot([0 0],[-10 10],'k:','LineWidth',1);plot([-10 10],[0 0],'k:','LineWidth',1)
xlabel('Z_r');ylabel('Z_i');
ylim([-.5 .2]);xlim([-.5,1]);box on;
text(-.9,.2,'(b)');
text(.8,.05,'\omega=0')
text(.07,-.14,'\omega_1')
text(.07,-.25,'\omega_2')
text(.42,-.35,'\omega \rightarrow \infty')


t = 0:.01:2.5;
Z2= -.2+(t-1).^2-.017*t.^5+(.25*t-.25*t.^2)*2i;
subplot(2,2,3); hold on;
rectangle('Position',[.55,-.6,1.03,1.7],'LineStyle','--','Edgecolor','k', 'FaceColor',[1 0.9 0. 0.4]);
rectangle('Position',[.55,-.6,.5,1.7],'LineStyle','--','Edgecolor','k', 'FaceColor',[0.91 0.41 0.17 0.5] );
plot(t,real(Z2),'b-',t,imag(Z2),'b--');hold on;
plot(t(75),real(Z2(75)),'bo')
plot(t(75),imag(Z2(75)),'bo')
plot([0.75 0.75], [-10 10],'k:','LineWidth',1);

plot(t,0*real(Z2),'k:','LineWidth',1)
xlabel('\omega');ylabel('Z_r, Z_i');
ylim([-.5 1]);xlim([0 2.5]); box on;
text(-.5,1,'(c)');
text(.8,.5,'\omega_0')
%text(1.32,.07,'\omega_2')

subplot(2,2,4);hold on;
xmin = -.5;
xmax = 0;
ymin = -2;
ymax = .5;
rectangle('Position',[xmin,ymin,xmax-xmin,ymax-ymin],'LineStyle','-','Edgecolor','none', 'FaceColor',[1 0.9 0. 0.4])
rectangle('Position',[xmin,0,xmax-xmin,ymax],'LineStyle','-','Edgecolor','none', 'FaceColor',[0.9100    0.4100    0.1700 0.5 ])
plot(real(Z2),imag(Z2),'b');
plot(real(Z2(75)),imag(Z2(75)),'bo')
plot([0 0],[-10 10],'k:','LineWidth',1);plot([-10 10],[0 0],'k:','LineWidth',1)
xlabel('Z_r');ylabel('Z_i');
ylim([-.8 .2]);xlim([-.5,1]);box on;
text(-.9,.2,'(d)');
text(.8,.05,'\omega=0')
text(-.3,.15,'\omega_0')
text(.22,-.75,'\omega \rightarrow \infty')

%box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos);
pause(0.1);
saveas(gcf,'Sketches_Impedance_Nyquist','png');
saveas(gcf,'Sketches_Impedance_Nyquist','fig');
pause(0.1);


