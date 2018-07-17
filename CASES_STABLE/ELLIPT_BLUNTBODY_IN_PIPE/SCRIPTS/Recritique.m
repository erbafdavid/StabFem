function [ReCS,ReCI,ImCI] = Recritique(guessReS,guessReI,EVS,EVI,Re_RangeS,Re_RangeI,bf,Hmax)

% Calcule les Reynolds critiques par interpolation polynomiale puis donne
% les valeurs propres des modes


%Calcul de Rec

xx= real(EVS);
kk=find(xx(2:end).*xx(1:end-1)<0);
i=kk;
j=kk+1;

XS=[Re_RangeS(i) Re_RangeS(j)];
YS=[real(EVS(i)) real(EVS(j))];

pS=polyfit(XS,YS,1);

ReCS=-pS(2)/pS(1);



xx= real(EVI);
kk=find(xx(2:end).*xx(1:end-1)<0);
k=kk;
l=kk+1;

XI=[Re_RangeI(k) Re_RangeI(l)];
YI=[real(EVI(k)) real(EVI(l))];

pI=polyfit(XI,YI,1);

ReCI=-pI(2)/pI(1);


%Calcul des coordonnées des modes au Reynolds critiques%

bf=SF_BaseFlow(bf,'Re',ReCS); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',guessReS,'nev',1);   
bf = SF_Adapt(bf,eigenmode00,'Hmax',Hmax);
[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',ev00,'nev',1);   
bf = SF_Adapt(bf,eigenmode00,'Hmax',Hmax);
[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',ev00,'nev',1,'plotspectrum','yes');

figure;
plotFF(eigenmode00,'ux1');
title('Profil de vitesse M1')
figure;
plotFF(eigenmode00,'vort1');
title('Ligne de vorticité M1')
figure;
plotFF(eigenmode00,'p1');
title('Lignes de pression M1')

bf=SF_BaseFlow(bf,'Re',ReCI); 
bf=SF_Adapt(bf,'Hmax',Hmax);

[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',guessReI,'nev',1);   
bf = SF_Adapt(bf,eigenmode01,'Hmax',Hmax);
[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',ev01,'nev',1);   
bf = SF_Adapt(bf,eigenmode01,'Hmax',Hmax);
[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',ev01,'nev',1,'plotspectrum','yes');

figure;
plotFF(eigenmode01,'ux1');
title('Profil de vitesse M2')
figure;
plotFF(eigenmode01,'vort1');
title('Ligne de vorticité M2')
figure;
plotFF(eigenmode01,'p1');
title('Lignes de pression M2')

% Résultats


ReCS
ev00

ReCI
ev01

ImCI=imag(ev01);

