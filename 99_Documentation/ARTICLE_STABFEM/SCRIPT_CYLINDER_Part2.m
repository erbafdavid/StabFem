% WNL model
[bf,em]=SF_FindThreshold(bf,em); Omegac=imag(em.lambda);
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','A'); 
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.,'Normalization','L');

epsilon2_WNL = -0.003:.0001:.005; 
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = wnl.Aeps*real(sqrt(epsilon2_WNL));

% HB model
Re_SC = [Rec 47 47.5 48 49 50 55 60 65 70 75 80 85 90 95 100];
Aenergy_SC  = [0]; 

for Re = Re_SC(2:end)
    [meanflow,mode] = SF_HB1(meanflow,mode,'Re',Re);
    Aenergy_SC  = [Aenergy_SC mode.AEnergy];
end

plot(Re_WNL,A_WNL,Re_SC,Aenergy_SC,'r+-'); % figure 7d.


