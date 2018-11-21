% initialisation
clear all
close all

%SF_Start
run('../../SOURCES_MATLAB/SF_Start.m');

% Latex plots 
% In case you do not have installed latex remove these latex
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');


%####
disp('Etape 1 : construction d''un maillage');
%####

% construction d'un maillage
bf = SF_Init('Mesh_1.edp');

% pour tracer le maillage : (peut prendre du temps...)
%plotFF(bf,'mesh');

%disp('Appuyez sur entree pour la suite...')
%pause; 
 
%####
disp('Etape 2 : resolution d''un pb force pour une valeur de k');
%#### 
 
% calcul d'un champ acoustique pour une valeur de k
%AC = SF_Acoustic(bf,'k',0.1)
Forced = SF_LinearForced(bf,1,'BC','SOMMERFELD');
Forced=SF_Adapt(Forced,'Hmax',0.1); % Adaptation du maillage
Forced = SF_LinearForced(bf,1,'BC','SOMMERFELD');

% trac? de la structure du champ acoustique
figure();
SF_Plot(Forced,'u','boundary','on','colormap','redblue');
figure();
SF_Plot(Forced,'p','boundary','on','colormap','redblue');


figure('DefaultAxesFontSize',18);
SF_Plot(Forced,'mesh');
hold on;plotFF(Forced,'u','mesh','off','boundary','on','colormap','redblue',...
                'colorbar','northoutside','cbtitle','u''_x','symmetry','YM'); % symmetry = XM means mirror about X-axis

% pour tracer Phi*r on peut faire : 
% AC.R = sqrt(AC.mesh.X.^2+AC.mesh.Y.^2);
% AC.PhiR = AC.Phi*AC.R;
% plotFF(AC,'PhiR')

% Pour tracer u et p sur l'axe :
  figure();
  plot(Forced.Xaxis,real(Forced.Paxis),'r-',Forced.Xaxis,imag(Forced.Paxis),'r--',...
               Forced.Xaxis,real(Forced.Uaxis),'b-',Forced.Xaxis,imag(Forced.Uaxis),'b--');
           title('Pressure and velocity along the axis ')
           legend('Re(P)', 'Im(P)','Re(U)','Im(U)'); 
           
Xaxis = [-10 :.1 :10];
Uyaxis = SF_ExtractData(Forced,'u',0,Xaxis);
figure();plot(Xaxis',real(Uyaxis'));ylabel('u_x''(x=0,y)'); xlabel('x');

% Remarque : on peut directement faire le calcul et les trac?s avec 
% la commande suivante :
% AC = SF_Acoustic(bf,'k',0.1,'plotPhi','yes','plotaxis','yes')

% Calcul de l'impedance pour plusieurs valeurs de k

disp('Appuyez sur entree pour la suite...')
pause; 

%###
disp('Etape 3 : boucle sur k pour trace de l''impedance');
%### 
IMPPML = SF_LinearForced(bf,[0.01:.01:2],'BC','PML','plot','no');
IMPCM = SF_LinearForced(bf,[0.01:.01:2],'BC','CM','plot','no');
IMP = SF_LinearForced(bf,[0.01:.01:2],'BC','SOMMERFELD','plot','no');

% trace de Z(k) parties reelles et imaginaires
figure(2);
plot(IMP.omega,real(IMP.Z),'b',IMP.omega,imag(IMP.Z),'b--','DisplayName','Sommerfeld');
hold on;
plot(IMPCM.omega,real(IMPCM.Z),'r',IMPCM.omega,imag(IMPCM.Z),'r--','DisplayName','CM');
plot(IMPPML.omega,real(IMPPML.Z),'k',IMPPML.omega,imag(IMPPML.Z),'k--','DisplayName','PML');
title(['Impedance $Z_r$ and $Z_i$'],'Interpreter','latex','FontSize', 30)
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$Z_r,Z_i$','Interpreter','latex','FontSize', 30);
leg=legend('Sommerfeld','CM','PML');
leg.FontSize = 20;
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
pause(0.1);
% trace de |Z(k)| en semilog
figure(3);
semilogy(IMP.omega,abs(IMP.Z),'b--','DisplayName','CM');
hold on;
semilogy(IMPCM.omega,abs(IMPCM.Z),'r--','DisplayName','CM');
semilogy(IMPPML.omega,abs(IMPPML.Z),'k--','DisplayName','CM');
xlabel('b'); ylabel('|Z|');
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$|Z|$','Interpreter','latex','FontSize', 30);
title(['Impedance $|Z|$'],'Interpreter','latex','FontSize', 30)
leg=legend('Sommerfeld','CM','PML');
leg.FontSize = 20;
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

pause(0.1);

figure(4);
semilogy(IMP.omega,IMP.R,'b--','DisplayName','Sommerfeld');
hold on;
semilogy(IMPCM.omega,IMPCM.R,'r--','DisplayName','CM');
semilogy(IMPPML.omega,IMPPML.R,'k--','DisplayName','PML');
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$R_i$','Interpreter','latex','FontSize', 30);
title(['Reflection coefficient'],'Interpreter','latex','FontSize', 30)
leg = legend('Sommerfeld','CM','PML');
leg.FontSize = 20;
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
% 
% k = [0.01:0.01:2.0];
% Z0 = 1/(2*pi);
% R = 1;
% L = 10;
% ZL = Z0*(k.^2*R^2/4 + 1i*k*0.35*R);
% Zin = Z0*(ZL.*cos(k*L)+1i*Z0*sin(k*L))./(1i*ZL.*sin(k*L)+Z0*cos(k*L))
% plot(k,-real(Zin),'k',k, -imag(Zin), 'k--');
% hold on;
% plot(IMP.k,real(IMP.Z),'b',IMP.k,imag(IMP.Z),'b--','DisplayName','Sommerfeld');
% 
% plot(k,real(Zin),'k',IMPPML.k,real(IMPPML.Z),'b');
% plot(k,-imag(Zin),'k',IMPCM.k,imag(IMPML.Z),'b');
