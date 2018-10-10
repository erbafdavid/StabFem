run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
close all;
set(0, 'DefaultLineLineWidth', 2);

%% Chapter 1 : mesh

Re = 1500;
chi = 1;
bf = SmartMesh_Hole(chi);
figure; plotFF(bf,'ux','title','Base Flow');
%Omega1 = .5;
%ForcedFlow1 = SF_Impedance(bf,Omega1);
%figure; plotFF(ForcedFlow1,'ux1','title','Response to Omega=0.5');
%Omega2 = 4;
%ForcedFlow2 = SF_Impedance(bf,Omega2);
%figure; plotFF(ForcedFlow2,'ux1','title','Response to Omega=4');
%bf = SF_Adapt(bf,ForcedFlow1,ForcedFlow2);


pause(0.1);

%% chapter 2 : impedances curves for Re=1500

bf = SF_BaseFlow(bf,'Re',1500)

II = SF_Launch('LoopImpedance.edp','Params',[1.8 0.1 2.3],'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);
figure;
subplot(1,2,1); hold on;
plot(II.Omega,real(II.Z),'r-',II.Omega,-imag(II.Z)/II.Omega,'r--'); 
xlabel('\omega');ylabel('Z_r, -Z_i/\omega');
title('Impedance for chi =1, Re = 1500' );

subplot(1,2,2)
plot(real(II.Z),imag(II.Z)); title('Nyquist diagram for chi =1, Re = 1000' );
rectangle('Position',[min(0,10*floor(min(real(II.Z/10))),floor(min(imag(II.Z)),0,ceil(max(II.Z))],'LineStyle','-','Edgecolor','none', 'FaceColor',[0.7 1 0.7 0.5])
rectangle('Position',[min(0,10*floor(min(real(II.Z/10))),floor(min(imag(II.Z)),0,ceil(max(II.Z))],'LineStyle','-','Edgecolor','none', 'FaceColor',[1 1 0.7 0.5])
xlabel('Z_r');ylabel('Z_i');
pause(0.1);

%% Chapter 3 : stability

bf = SF_BaseFlow(bf,'Re',1500);
[ev,em] = SF_Stability(bf,'m',0,'shift',-.036-2.050i,'nev',20,'solver','StabAxiCOMPLEX_m0.edp','plotspectrum','yes')
figure;plotFF(em,'ux1');

Re_tab = [1500 : 50 : 1700]; ev_tab = []; 
ev_tab = SF_Stability_LoopRe(bf,Re_tab,ev);
plot(Re_tab,real(ev_tab),Re_tab,imag(ev_tab));

II = SF_Launch('LoopImpedance.edp','Params',[0 0.1 6],'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);
figure; plot(II.Omega,real(II.Z),II.Omega,imag(II.Z)); title(['Impedance for chi = ' num2str(chi) ', Re = ' num2str(Re) ] );
pause(0.1);


%% Chapter 4 (to recast) 
%REtab = [800 1200 1500];OmegaRange = [0 .1 8];ColorRange='gmr';
%for k = 1:length(REtab)
%    Re = REtab(k);
%    bf = SF_BaseFlow(bf,'Re',Re);
%    II(k) = SF_Launch('LoopImpedance.edp','Params',OmegaRange,'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);
%    figure(1);hold on;plot(II(k).Omega,real(II(k).Z),[ColorRange(k) '-']);plot(II(k).Omega,imag(II(k).Z),[ColorRange(k) '--']);
%    figure(2);hold on;plot(II(k).Z,[ColorRange(k) '-']);
%    pause(0.1);
%end
