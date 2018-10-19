% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  THIS SCRIPT DEMONSTRATES HOW TO COMPUTE IMPEDANCE 
%
% Revised by David & Diogo on oct 18

if(exist('bf')==1)
    disp('Mesh / base flow previously computed');
else
    bf = SmartMesh_Cylinder('S');
end


close all;

%% Re = 40 , ANCIENNE METHODE

%bf=SF_BaseFlow(bf,'Re',20);
%[Omegatab,Ltab,Mtab]=FreeFem_HarmonicForcing(bf);
%pause;

%% Re = 40, NOUVELLE METHODE
Re = 40;
bf=SF_BaseFlow(bf,'Re',Re);
OmegaRange = [0 : .05 : 1];
II = SF_LinearForced(bf,OmegaRange);

figure(20);
subplot(1,2,1); hold on;
plot(II.omega,real(II.Z),'b-',II.omega,imag(II.Z)./II.omega,'b--');hold on;
plot(II.omega,0*real(II.Z),'k:','LineWidth',1)
xlabel('\omega');ylabel('Z_r, Z_i/\omega');box on;
title(['Impedance for Re = ',num2str(Re)] );
subplot(1,2,2);hold on;
plot(real(II.Z),imag(II.Z)); title(['Nyquist diagram for Re =',num2str(Re)] );
xlabel('Z_r');ylabel('Z_i');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos);
pause(0.1);
saveas(gcf,['Impedance_and_Nyquist_Re',num2str(Re)],'png');
saveas(gcf,['Impedance_and_Nyquist_Re',num2str(Re)],'fig');
pause(0.1);

