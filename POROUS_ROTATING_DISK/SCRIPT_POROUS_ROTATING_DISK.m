
run('../SOURCES_MATLAB/SF_Start.m');
ffdatadir = './'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational
verbosity=100;
AspectRatio = 0.7;
figureformat = 'png';

% Chapter 1 : generation of a baseflow and a mesh for Re=200
baseflow=SF_Init('mesh_Disk.edp');
baseflow=SF_BaseFlow(baseflow,'Re',10,'Porosity',1e-3,'Omegax',0.1);

baseflow = SF_Adapt(baseflow,'Hmin',5e-3);
baseflow=SF_BaseFlow(baseflow,'Re',30);
baseflow=SF_BaseFlow(baseflow,'Re',100);
baseflow=SF_BaseFlow(baseflow,'Re',200);
baseflow = SF_Adapt(baseflow);

baseflow.xlim = [-2 4]; baseflow.ylim=[0,3];
plotFF(baseflow,'ux');pause(0.1);

% Chapter 2 : Spectrum exploration

% first exploration for m=1
[ev1,em1] = SF_Stability(baseflow,'m',1,'shift',0.2-.6i,'nev',10);
[ev2,em2] = SF_Stability(baseflow,'m',1,'shift',0.2,'nev',10);
[ev3,em3] = SF_Stability(baseflow,'m',1,'shift',0.2+.6i,'nev',10);
plot(real(ev1),imag(ev1),'+',real(ev2),imag(ev2),'+',real(ev3),imag(ev3),'+');
title('spectrum for m=1, Re=200, Omega=0.1, Porosity=0.001')

% Chapter 3 : stability curves

Re_LIN = [200 : 2.5: 220];

baseflow=SF_BaseFlow(baseflow,'Re',200);
[ev,em] = SF_Stability(baseflow,'m',1,'shift',ev1(1),'nev',1);
lambda1_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda1_LIN = [lambda1_LIN ev];
    end    

baseflow=SF_BaseFlow(baseflow,'Re',200);
[ev,em]=SF_Stability(baseflow,'m',1,'shift',ev2(1),'nev',1);
lambda2_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda2_LIN = [lambda2_LIN ev];
    end   
    
baseflow=SF_BaseFlow(baseflow,'Re',200);
[ev,em]=SF_Stability(baseflow,'m',1,'shift',ev3(1),'nev',1);
lambda3_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda3_LIN = [lambda3_LIN ev];
    end   

figure(20);
plot(Re_LIN,real(lambda1_LIN),'b+-',Re_LIN,real(lambda1_LIN),'r+-',Re_LIN,real(lambda3_LIN),'b+-');
xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'PorousDisk_sigma_Re',figureformat);

figure(21);hold off;
plot(Re_LIN,imag(lambda1_LIN),'b+-',Re_LIN,imag(lambda1_LIN),'r+-',Re_LIN,imag(lambda3_LIN),'b+-');
xlabel('Re');ylabel('$\omega');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'PorousDisk_omega_Re',figureformat);    
    
