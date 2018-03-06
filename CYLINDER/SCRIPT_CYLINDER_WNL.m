
verbosity = 11;

%%% CHAPTER 4 : determination of critical reynolds number

if(exist('Rec')==1)
    disp('INSTABILITY THRESHOLD ALREADY COMPUTED');
else 
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
baseflow=SF_BaseFlow(baseflow,'Re',50);
[ev,em] = SF_Stability(baseflow,'shift',+.75i,'nev',1,'type','S');
[baseflow,em]=SF_FindThreshold(baseflow,em);
Rec = baseflow.Re;  Cxc = baseflow.Cx; 
Lxc=baseflow.Lx;    Omegac=imag(em.lambda);

end

baseflow=SF_BaseFlow(baseflow,Rec);
[ev,em] = SF_Stability(baseflow,'shift',em.lambda,'type','S','nev',1);
wnl = SF_WNL(baseflow);

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = sqrt(real(wnl.Lambda)/real(wnl.nu0+wnl.nu2))*real(sqrt(epsilon2_WNL));
Cy_WNL = abs(em.Cy)/sqrt(em.Energy)*A_WNL; 
omega_WNL =Omegac+epsilon2_WNL*imag(wnl.Lambda)-imag(wnl.nu0+wnl.nu2)*A_WNL.^2;
%omega_WNLno2 =Omegac+epsilonRANGE.*(imag(wnl.Lambda)-real(wnl.Lambda)*imag(wnl.nu0)/real(wnl.nu0));
Cx_WNL = wnl.Cx0+wnl.Cxeps*epsilon2_WNL+wnl.Cx20*A_WNL.^2;

figure(20);hold on;
plot(Re_WNL,real(wnl.Lambda)*epsilon2_WNL,'g--');hold on;

figure(21);hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--');hold on;

figure(22);hold on;
plot(Re_WNL,Cx_WNL,'g--');hold on;

figure(24); hold on;
plot(Re_WNL,Cy_WNL,'g--');

figure(25);hold on;
plot(Re_WNL,A_WNL,'g--');
