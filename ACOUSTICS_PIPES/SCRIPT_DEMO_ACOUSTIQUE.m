% initialisation
clear all
close all

SF_Start
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
AC = SF_Acoustic(bf,'k',0.1)

% trac? de la structure du champ acoustique
plotFF(AC,'Phi');


% pour tracer Phi*r on peut faire : 
% AC.R = sqrt(AC.mesh.X.^2+AC.mesh.Y.^2);
% AC.PhiR = AC.Phi*AC.R;
% plotFF(AC,'PhiR')

% Pour tracer u et p sur l'axe :
  figure(2);
  plot(AC.Xaxis,real(AC.Paxis),'r-',AC.Xaxis,imag(AC.Paxis),'r--',...
               AC.Xaxis,real(AC.Uaxis),'b-',AC.Xaxis,imag(AC.Uaxis),'b--');
           title('Pressure and velocity along the axis ')
           legend('Re(P)', 'Im(P)','Re(U)','Im(U)'); 
  

% Remarque : on peut directement faire le calcul et les trac?s avec 
% la commande suivante :
% AC = SF_Acoustic(bf,'k',0.1,'plotPhi','yes','plotaxis','yes')

% Calcul de l'impedance pour plusieurs valeurs de k

disp('Appuyez sur entree pour la suite...')
pause; 

%###
disp('Etape 2 : resolution d''un pb force pour une valeur de k');
%### 
 
IMP = SF_Acoustic_Impedance(bf,'k',[0:.01:2])

% trace de Z(k) parties reelles et imaginaires
figure(3);
plot(IMP.k,real(IMP.Z),'b',IMP.k,imag(IMP.Z),'b--');
title('Impedance : real and imaginary parts')
xlabel('k'); ylabel('Z_r,Z_i')
pause(0.1);

% trace de |Z(k)| en semilog
figure(4);
semilogy(IMP.k,abs(IMP.Z));
title('Impedance : absolute value, semilog plot')
xlabel('k'); ylabel('|Z|');
pause(0.1);

% trace de R(k)
figure(5);
semilogy(IMP.k,IMP.R);
title('Reflexion coefficient')
xlabel('k'); ylabel('R')



