run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
close all;

Re = 1000;
chi = 1;
bf = SmartMesh_Hole(chi);
figure; plotFF(bf,'ux','title','Base Flow');

pause;

bf = SF_BaseFlow(bf,'Re',1500)

Omega1 = .5;
ForcedFlow1 = SF_Impedance(bf,Omega1);
figure; plotFF(ForcedFlow1,'ux1','title','Response to Omega=0.5');
Omega2 = 4;
ForcedFlow2 = SF_Impedance(bf,Omega2);
figure; plotFF(ForcedFlow2,'ux1','title','Response to Omega=4');

bf = SF_Adapt(bf,ForcedFlow1,ForcedFlow2);

II = SF_Launch('LoopImpedance.edp','Params',[1.8 0.1 2.3],'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);
figure; plot(II.Omega,real(II.Z),II.Omega,imag(II.Z)); title('Impedance for chi =1, Re = 1000' );
figure; plot(real(II.Z),imag(II.Z)); title('Nyquist diagram for chi =1, Re = 1000' );


pause;

bf = SF_BaseFlow(bf,'Re',1500);
[ev,em] = SF_Stability(bf,'m',0,'shift',-.036-2.050i,'nev',1)
figure;plotFF(em,'ux1');

Re_tab = [1500 : 50 : 1700]; ev_tab = []; 
for Re = Re_tab
    bf = SF_BaseFlow(bf,'Re',Re);
    [ev,em] = SF_Stability(bf,'m',0,'shift','prev','nev',1)
    ev_tab = [ev_tab ev]
end
plot(Re_tab,real(ev_tab),Re_tab,imag(ev_tab));

II = SF_Launch('LoopImpedance.edp','Params',[0 0.1 6],'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);
figure; plot(II.Omega,real(II.Z),II.Omega,imag(II.Z)); title(['Impedance for chi = ' num2str(chi) ', Re = ' num2str(Re) ] );


