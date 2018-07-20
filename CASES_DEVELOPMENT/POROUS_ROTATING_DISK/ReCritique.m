function [ReC,ev,em,baseflow] = ReCritique(baseflow,Re,lambda,m,ffig)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

global boxx boxy;

% Reynolds Critique

Real = real(lambda);
Zero = find(Real(2:end).*Real(1:end-1)<0);
i = Zero;
ii = Zero+1;

shift = lambda(i);

x = [Re(i) Re(ii)];
y = [real(lambda(i)) real(lambda(ii))];

poly = polyfit(x,y,1);
ReC = -poly(2)/poly(1);

% Mode des Reynolds Critique

% baseflow = SF_BaseFlow(baseflow,'Re',ReC);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-5);
% 
% for a=1:2
%     [ev,em] = SF_Stability(baseflow,'m',m,'shift',shift,'nev',1);
%     baseflow = SF_Adapt(baseflow,em,'Hmin',1e-5);
% end
[ev,em] = SF_Stability(baseflow,'m',m,'shift',shift,'nev',1);

if (ffig==1)
    figure();
    subplot(2,2,1)
        plotFF(em,'ux1','title',['Vitesse u_x - m = ' num2str(em.m) ' - Rec = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula')
        xlabel('x')
        ylabel('r')
        hold on
        plot(boxx, boxy, 'w-')
        hold off
    subplot(2,2,2)
        plotFF(em,'uy1','title',['Vitesse u_y - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula')
        xlabel('x')
        ylabel('r')
        hold on
        plot(boxx, boxy, 'w-')
        hold off
    subplot(2,2,3)
        plotFF(em,'p1','title',['Pression P - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula')
        xlabel('x')
        ylabel('r')
        hold on
        plot(boxx, boxy, 'w-')
        hold off
    subplot(2,2,4)
        plotFF(em,'vort1','title',['Vorticité \omega - m = ' num2str(em.m) ' - Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)],'ColorMap','parula')
        xlabel('x')
        ylabel('r')
        hold on
        plot(boxx, boxy, 'w-')
        hold off;
end

% Résultats

disp(' ');
disp(' #################### ');
disp(' ');
disp([' Reynolds Critique = ' num2str(ReC)]);
disp([' Valeur P Critique = ' num2str(ev)]);
disp(' ');
disp(' #################### ');
disp(' ');
end

