close all;
run('../../SOURCES_MATLAB/SF_Start.m');verbosity=100;
system('mkdir FIGURES');
figureformat = 'png';
%% CHAPTER 0 : creation of initial mesh sessile drops
gamma=0.002;
rhog=1;
R = 1;
L =2;
typestart = 'pined';
typeend = 'axis';

density=200;
 %creation of an initial mesh 
ffmesh = SF_Mesh('MeshInit_Vessel.edp','Params',[L density]);
%figure();plot(ffmesh.xsurf,ffmesh.ysurf);hold on;quiver(ffmesh.xsurf,ffmesh.ysurf,ffmesh.N0r,ffmesh.N0z);
P = -0.035;
ffmesh = SF_Mesh_Deform(ffmesh,'P',P,'gamma',gamma,'rhog',rhog,'typestart',typestart,'typeend',typeend);
Vol0 = ffmesh.Vol; 
figure(1);hold off;
plot(ffmesh.xsurf,ffmesh.ysurf); hold

%% CHAPTER 1 : Eigenvalue computation for m=0 and m=1 FOR A Sessile drop
[evm0,emm0] =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA','typestart','pined','typeend','axis');
[evm1,emm1] =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA','typestart','pined','typeend','axis');

%%% PLOT RESULTS
%%% PLOT RESULTS
figure(2);
plot(imag(evm0),real(evm0),'ro',imag(evm1),real(evm1),'bo');
title('Vessel, spectra for m=0 (red) and m=1 (blue)');
xlabel('\omega_r');ylabel('\omega_i');

figure(3); hold off;
plot(ffmesh.S0,real(emm0(3).eta));hold on;
plot(ffmesh.S0,real(emm0(5).eta));
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
plot(ffmesh.S0,real(emm1(1).eta));
plot(ffmesh.S0,real(emm1(3).eta));
% on the other hand for m=1 the first modes are regular
title('Vessel structure of the four simplest modes eta(s) ');
legend('m=0,a','m=0,s','m=1,s','m=1,a');


figure(4);
subplot(1,4,1);plotFF(emm0(3),'phi.im','title','Mode m=0,k=2');
hold on;E=0.15/max(abs(emm0(3).eta));
plot(ffmesh.xsurf+E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'r');hold off;
subplot(1,4,2);plotFF(emm0(5),'phi.im','title','Mode m=0,k=4');
hold on;E=0.15/max(abs(emm0(5).eta));
plot(ffmesh.xsurf+E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'r');hold off;
subplot(1,4,3);plotFF(emm1(1),'phi.im','title','Mode m=1,k=1');
E=0.15/max(abs(emm1(1).eta));
hold on;plot(ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'r');
subplot(1,4,4);plotFF(emm1(3),'phi.im','title','Mode m=1,k=3');
E=0.15/max(abs(emm1(3).eta));
hold on;plot(ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'r');
pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
%set(gca,'FontSize', 14);
saveas(gcf,'FIGURES/Vessel_Eigenmodes',figureformat);
%pause;


figure(5); hold on;
E=0.15/max(abs(real(emm0(3).eta)));
plot(ffmesh.xsurf+E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'b');
plot(-ffmesh.xsurf-E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'b','HandleVisibility','off');

E=0.15/max(abs(emm0(5).eta));
plot(ffmesh.xsurf+E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'r');
plot(-ffmesh.xsurf-E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'r','HandleVisibility','off');

E=0.15/max(abs(emm1(1).eta));
plot(ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'g');
plot(-ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf-E*real(emm1(1).eta).*ffmesh.N0z,'g','HandleVisibility','off');

E=0.15/max(abs(real(emm1(3).eta)));
plot(ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'c');
plot(-ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf-E*real(emm1(3).eta).*ffmesh.N0z,'c','HandleVisibility','off');


% draw mean shape, end limits and axis
plot(ffmesh.xsurf,ffmesh.ysurf,'k');
plot(-ffmesh.xsurf,ffmesh.ysurf,'k');
plot([ffmesh.xsurf(1), -ffmesh.xsurf(1)],[-1, -1],'k','LineWidth',4);
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[-1, -1],'k','LineWidth',4);

plot([-1, -1],[0.2, -1],'k','LineWidth',3);
plot([-1, -1],[0.2, -1],'k','LineWidth',3);

plot([1, 1],[0.2, -1],'k','LineWidth',3);
plot([1, 1],[0.2, -1],'k','LineWidth',3);


legend('m=0,k=2','m=0,k=4','m=1,k=1','m=1,k=3','Location','south');
box on; pos = get(gcf,'Position'); pos(3)=pos(4)*.8;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 12);
grid on
saveas(gcf,'FIGURES/SessileDrops__Eigenmodes_eta',figureformat);
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
