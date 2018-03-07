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
figure(1);
plotFF(AC,'Phi');
% pour tracer Phi*r on peut faire : 
% AC.R = sqrt(AC.mesh.X.^2+AC.mesh.Y.^2);
% AC.PhiR = AC.Phi*AC.R;
% plotFF(AC,'PhiR')

% Calcul de l'impedance pour plusieurs valeurs de k
figure(2);
IMP = SF_Acoustic_Impedance(bf,'k',[0:.1:2])

% trace de Z(k) parties reelles et imaginaires
figure(3);
plot(IMP.k,real(IMP.Z),'b',IMP.k,imag(IMP.Z),'b--');
% trace de |Z(k)| en semilog
figure(4);
semilogy(IMP.k,abs(IMP.Z));
% trace de R(k)
%semilogy(IMP.k,IMP.R);



