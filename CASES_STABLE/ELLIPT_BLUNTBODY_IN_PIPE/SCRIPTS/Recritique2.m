function [ReCI1,ReCI2,ImCI1,ImCI2] = Recritique2(guessReI1,guessReI2,EVI1,EVI2,Re_RangeI1,Re_RangeI2,bf,Hmax)

%%Calcule les Reynolds critiques par interpolation polynomiale puis donne
%%leur coordonnées dans le plan complexe



%Calcul de Rec


xx= real(EVI1);
kk=find(xx(2:end).*xx(1:end-1)<0);
i=kk;
j=kk+1;

XS=[Re_RangeI1(i) Re_RangeI1(j)];
YS=[real(EVI1(i)) real(EVI1(j))];

pS=polyfit(XS,YS,1);

ReCI1=-pS(2)/pS(1);



xx= real(EVI2);
kk=find(xx(2:end).*xx(1:end-1)<0);
k=kk;
l=kk+1;

XI=[Re_RangeI2(k) Re_RangeI2(l)];
YI=[real(EVI2(k)) real(EVI2(l))];

pI=polyfit(XI,YI,1);

ReCI2=-pI(2)/pI(1);

%Calcul des coordonnées des modes au Reynolds critique%

bf=SF_BaseFlow(bf,'Re',ReCI1); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',guessReI1,'nev',1);   
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



bf=SF_BaseFlow(bf,'Re',ReCI2); 
bf=SF_Adapt(bf,'Hmax',Hmax); % bf = SF_Adapt(bf,em,'Hmax',Hmax);

[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',guessReI2,'nev',1);   
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


ReCI1
ev00

ImCI1=imag(ev00);


ReCI2
ev01

ImCI2=imag(ev01);

