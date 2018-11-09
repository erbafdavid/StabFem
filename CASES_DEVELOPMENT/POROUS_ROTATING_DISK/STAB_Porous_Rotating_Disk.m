%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%                    -- SPECTRUM EXPLORATION --
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%                                                   
%#####################################################################

%% 3 - Spectrum exploration


% first exploration for m=1
[ev1,em1] = SF_Stability(baseflow,'m',1,'shift',1-1i,'nev',10,'PlotSpectrum','yes');
[ev2,em2] = SF_Stability(baseflow,'m',1,'shift',1,'nev',10,'PlotSpectrum','yes');
[ev3,em3] = SF_Stability(baseflow,'m',1,'shift',1+1i,'nev',10,'PlotSpectrum','yes');

em = em22;
% Plot EV_ux
figure;
plotFF(em,'ux1','title',['Champ de vitesse u_x pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','jet');
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot EV_uy
figure;
plotFF(em,'uy1','title',['Champ de vitesse u_y pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','jet');
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot EV_p
figure;
plotFF(em,'p1','title',['Champ de pression P pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','jet');
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot EV_Vort
figure;
plotFF(em,'vort1','title',['Champ de vorticité \omega pour \lambda = ' num2str(em.lambda) ' - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','jet');
hold on;plot(boxx, boxy, 'w-');hold off;

figure;
plot(real(ev1),imag(ev1),'+',real(ev2),imag(ev2),'+',real(ev3),imag(ev3),'+');
title(['spectrum for m=1, Re=' num2str(baseflow.Re) ', Omega=' num2str(Omega) ', Porosity=' num2str(Porosite)])
