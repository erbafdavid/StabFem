close all;
run('../../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';
%% CHAPTER 0 : creation of initial mesh sessile drops

R = 1;
theta = 70;
density=70;
 %creation of an initial mesh 
ffmesh = SF_Mesh('MeshInit_Drop.edp','Params',[R theta density]);
%figure();plot(ffmesh.xsurf,ffmesh.ysurf);hold on;quiver(ffmesh.xsurf,ffmesh.ysurf,ffmesh.N0r,ffmesh.N0z);

%% CHAPTER 1 : Eigenvalue computation for m=0 and m=1 FOR A Sessile drop
[evm0,emm0] =  SF_Stability(ffmesh,'nev',10,'m',0,'sort','SIA','typestart','pined','typeend','axis');
[evm1,emm1] =  SF_Stability(ffmesh,'nev',10,'m',1,'sort','SIA','typestart','pined','typeend','axis');
figure();
plotFF(emm0(3),'mesh');
hold on
plot(ffmesh.xsurf,ffmesh.ysurf);hold on;quiver(ffmesh.xsurf,ffmesh.ysurf,ffmesh.N0r,ffmesh.N0z);

%%% PLOT RESULTS
figure(2);
plot(imag(evm0),real(evm0),'ro',imag(evm1),real(evm1),'bo');
title('Sessile Drops, L= 4 : spectra for m=0 (red) and m=1 (blue)');
xlabel('\omega_r');ylabel('\omega_i');

figure(3); hold off;
plot(ffmesh.S0,real(emm0(3).eta));hold on;
plot(ffmesh.S0,real(emm0(5).eta));
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
plot(ffmesh.S0,real(emm1(1).eta));
plot(ffmesh.S0,real(emm1(3).eta));
% on the other hand for m=1 the first modes are regular
title('Sessile Drops, L= 4 : structure of the four simplest modes eta(s) ');
legend('m=0,a','m=0,s','m=1,s','m=1,a');


figure(4);
subplot(2,2,1);plotFF(emm0(3),'phi.im','title','Mode m=0,k=2');
hold on;E=0.15/max(abs(emm0(3).eta));
plot(ffmesh.xsurf+E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'r');hold off;
subplot(2,2,2);plotFF(emm0(5),'phi.im','title','Mode m=0,k=4');
hold on;E=0.15/max(abs(emm0(5).eta));
plot(ffmesh.xsurf+E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'r');hold off;
subplot(2,2,3);plotFF(emm1(1),'phi.im','title','Mode m=1,k=1');
E=0.15/max(abs(emm1(1).eta));
hold on;plot(ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'r');
subplot(2,2,4);plotFF(emm1(3),'phi.im','title','Mode m=1,k=3');
E=0.15/max(abs(emm1(3).eta));
hold on;plot(ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'r');
pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
%set(gca,'FontSize', 14);
saveas(gcf,'FIGURES/SessileDrops_Eigenmodes',figureformat);
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
plot([ffmesh.xsurf(1), -ffmesh.xsurf(1)],[ffmesh.ysurf(1), ffmesh.ysurf(1)],'k','LineWidth',3);
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[ffmesh.ysurf(end), ffmesh.ysurf(end)],'k','LineWidth',3);
plot([0,0],[ffmesh.ysurf(1), ffmesh.ysurf(end)],'k:');
legend('m=0,k=2','m=0,k=4','m=1,k=1','m=1,k=3');
box on; pos = get(gcf,'Position'); pos(3)=pos(4)*.8;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 12);
saveas(gcf,'FIGURES/SessileDrops__Eigenmodes_eta',figureformat);
% note that for m=0 the two first modes are spurious, so we take modes 3 and 5
%%
%pause(0.1);

figure(6); 
subplot(2,2,1); hold on;
E=0.15/max(abs(real(emm0(3).eta)));
plot(ffmesh.xsurf+E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'k');
plot(-ffmesh.xsurf-E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'k','HandleVisibility','off');
area(ffmesh.xsurf+E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'FaceColor','k')
area(-ffmesh.xsurf-E*real(emm0(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(3).eta).*ffmesh.N0z,'FaceColor','k')
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[ffmesh.ysurf(end), ffmesh.ysurf(end)],'k','LineWidth',3);
title('Mode m=0,k=2')

subplot(2,2,2); hold on;
E=0.15/max(abs(emm0(5).eta));
plot(ffmesh.xsurf+E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'k');
plot(-ffmesh.xsurf-E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'k','HandleVisibility','off');
area(ffmesh.xsurf+E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'FaceColor','k')
area(-ffmesh.xsurf-E*real(emm0(5).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm0(5).eta).*ffmesh.N0z,'FaceColor','k')
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[ffmesh.ysurf(end), ffmesh.ysurf(end)],'k','LineWidth',3);
title('Mode m=0,k=4')

subplot(2,2,3); hold on;
E=0.15/max(abs(emm1(1).eta));
plot(ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'k');
plot(-ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf-E*real(emm1(1).eta).*ffmesh.N0z,'k','HandleVisibility','off');
area(ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(1).eta).*ffmesh.N0z,'FaceColor','k')
area(-ffmesh.xsurf+E*real(emm1(1).eta).*ffmesh.N0r,ffmesh.ysurf-E*real(emm1(1).eta).*ffmesh.N0z,'FaceColor','k')
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[ffmesh.ysurf(end), ffmesh.ysurf(end)],'k','LineWidth',3);
title('Mode m=1,k=1')

subplot(2,2,4); hold on;
E=0.15/max(abs(real(emm1(3).eta)));
plot(ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'k');
plot(-ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf-E*real(emm1(3).eta).*ffmesh.N0z,'k','HandleVisibility','off');
area(ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf+E*real(emm1(3).eta).*ffmesh.N0z,'FaceColor','k')
area(-ffmesh.xsurf+E*real(emm1(3).eta).*ffmesh.N0r,ffmesh.ysurf-E*real(emm1(3).eta).*ffmesh.N0z,'FaceColor','k')
plot([ffmesh.xsurf(end), -ffmesh.xsurf(end)],[ffmesh.ysurf(end), ffmesh.ysurf(end)],'k','LineWidth',3);
title('Mode m=1,k=3')
saveas(gcf,'FIGURES/SessileDrops_subplot_Eigenmodes_eta',figureformat);




