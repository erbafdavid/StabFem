% initialisation
clear all
close all

SF_Start

% construction d'un maillage
bf = SF_Init('Mesh_1.edp');

% pour tracer le maillage decomenter la ligne suivante :
% plotFF(bf,'mesh');

% calcul d'un champ acoustique pour une valeur de k
AC = SF_Acoustic(bf,'k',0.1)

% trac? de la structure du champ acoustique
plotFF(AC,'Phi');
pause(0.1);

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
  pause(0.1);

% Remarque : on peut directement faire le calcul et les trac?s avec 
% la commande suivante :
% AC = SF_Acoustic(bf,'k',0.1,'plotPhi','yes','plotaxis','yes')

% Calcul de l'impedance pour plusieurs valeurs de k

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
pause(0.1);
title('Impedance : absolute value, semilog plot')
xlabel('k'); ylabel('|Z|')

% trace de R(k)
semilogy(IMP.k,IMP.R);
title('Reflexion coefficient')
xlabel('k'); ylabel('R')



