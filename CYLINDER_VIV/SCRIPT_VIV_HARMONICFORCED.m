% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  THIS SCRIPT DEMONSTRATES THE MESH CONVERGENCE USING ADAPTMESH 
%   TO BASEFLOW AND EIGENMODE.


global ff ffdir ffdatadir sfdir verbosity
ff = '/usr/local/bin/FreeFem++-nw'; %% Freefem command with full path 
ffdatadir = './DATA_FREEFEM_CYLINDER';
sfdir = '../SOURCES_MATLAB'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts
verbosity=1;


addpath(sfdir);
system(['mkdir ' ffdatadir]);

if(exist('em')==1)
    disp('Mesh / base flow previously computed');
else

disp(' ');
disp(' GENERATING  MESH : [-40:120]x[0:40] ');
disp(' ');

baseflow=SF_Init('Mesh_Cylinder_Large.edp');
baseflow=FreeFem_BaseFlow(baseflow,'Re',1);
baseflow=FreeFem_BaseFlow(baseflow,'Re',10);
baseflow=FreeFem_BaseFlow(baseflow,'Re',60);
plotFF(baseflow,'mesh');pause;

baseflow=FreeFem_Adapt(baseflow,'Hmax',10,'InterpError',0.005);
plotFF(baseflow,'mesh');pause(0.1);

disp(' ');
disp('ADAPTING MESH FOR RE=60 ')
disp(' ');
%baseflow=FreeFem_BaseFlow(baseflow,'Re',60);

[ev,em] = FreeFem_Stability(baseflow,'shift',0.04+0.76i,'nev',1,'type','S');
[baseflow,em]=FreeFem_Adapt(baseflow,em,'Hmax',10,'InterpError',0.01);
plotFF(baseflow,'mesh');pause(0.1);


end


%disp(' ');
%disp(' THRESHOLD : ')
%[baseflowC,emC]=FreeFem_FindThreshold(baseflow,em);


close all;

baseflow=FreeFem_BaseFlow(baseflow,'Re',20);
[Omegatab,Ltab,Mtab]=FreeFem_HarmonicForcing(baseflow);
figure(3);hold on;title('Re (Y) as function of omega');
plot(Omegatab,real(Ltab));
figure(4);hold on;title('Im (Y) as function of omega');
plot(Omegatab,imag(Ltab));
figure(5);hold on;title('Re (Z) as function of omega');
plot(Omegatab,real(1/Ltab));
figure(6);hold on;title('Im (Z) as function of omega');
plot(Omegatab,imag(1/Ltab));




baseflow=FreeFem_BaseFlow(baseflow,'Re',30);
[Omegatab,Ltab,Mtab]=FreeFem_HarmonicForcing(baseflow);
figure(3);hold on;title('Re (Y) as function of omega');
plot(Omegatab,real(Ltab));
figure(4);hold on;title('Im (Y) as function of omega');
plot(Omegatab,imag(Ltab));
figure(5);hold on;title('Re (Z) as function of omega');
plot(Omegatab,real(1./Ltab));
figure(6);hold on;title('Im (Z) as function of omega');
plot(Omegatab,imag(1./Ltab));


baseflow=FreeFem_BaseFlow(baseflow,'Re',40);
[Omegatab,Ltab,Mtab]=FreeFem_HarmonicForcing(baseflow);
figure(3);hold on;title('Re (Y) as function of omega');
plot(Omegatab,real(Ltab));
figure(4);hold on;title('Im (Y) as function of omega');
plot(Omegatab,imag(Ltab));
figure(5);hold on;title('Re (Z) as function of omega');
plot(Omegatab,real(1./Ltab));
figure(6);hold on;title('Im (Z) as function of omega');
plot(Omegatab,imag(1./Ltab));


baseflow=FreeFem_BaseFlow(baseflow,'Re',50);
[Omegatab,Ltab,Mtab]=FreeFem_HarmonicForcing(baseflow);
figure(3);hold on;title('Re (Y) as function of omega');
plot(Omegatab,real(Ltab));
figure(4);hold on;title('Im (Y) as function of omega');
plot(Omegatab,imag(Ltab));
figure(5);hold on;title('Re (Z) as function of omega');
plot(Omegatab,real(1./Ltab));
figure(6);hold on;title('Im (Z) as function of omega');
plot(Omegatab,imag(1./Ltab));



baseflow=FreeFem_BaseFlow(baseflow,'Re',60);
[Omegatab,Ltab,Mtab]=FreeFem_HarmonicForcing(baseflow);
figure(3);hold on;title('Re (Y) as function of omega');
plot(Omegatab,real(Ltab));
figure(4);hold on;title('Im (Y) as function of omega');
plot(Omegatab,imag(Ltab));
figure(5);hold on;title('Re (Z) as function of omega');
plot(Omegatab,real(1./Ltab));
figure(6);hold on;title('Im (Z) as function of omega');
plot(Omegatab,imag(1./Ltab));





figure(3);
legend('Re=20', 'Re=30', 'Re=40', 'Re=50', 'Re=60','Location','southwest')

figure(4);
legend('Re=20', 'Re=30', 'Re=40', 'Re=50', 'Re=60','Location','southwest')

figure(5);
legend('Re=20', 'Re=30', 'Re=40', 'Re=50', 'Re=60','Location','southwest')

figure(6);
legend('Re=20', 'Re=30', 'Re=40', 'Re=50', 'Re=60','Location','southwest')

figure(3); plot(Omegatab,0*Omegatab,'k:')
figure(5); plot(Omegatab,0*Omegatab,'k:')

if(1==0)

disp(' ');
disp('COMPUTING STABILITY BRANCH (fixed cylinder) ')
disp(' ');
% starting point
baseflow=FreeFem_BaseFlow(baseflow,'Re',40);
[ev,em] = FreeFem_Stability(baseflow,'shift',-.03+.72i,'nev',1,'type','D');




Re_tab = [40 : 5 : 80];
sigma_tab = [];
for Re = Re_tab
    baseflow = FreeFem_BaseFlow(baseflow,'Re',Re);
    [ev,em] = FreeFem_Stability(baseflow,'shift','cont','nev',1,'type','D');
    sigma_tab = [sigma_tab ev];
end
figure(1);hold on;
plot(Re_tab,real(sigma_tab),'r*');
title('amplification rate');

figure(2);hold on;
plot(Re_tab,imag(sigma_tab),'b*');
title('oscillation rate');
pause(0.1);




end
if(1==0)

disp(' ');
disp('COMPUTING STABILITY BRANCH FOR VIV CASE (M=10,K=1) ')
disp(' ');
% starting point
baseflow=FreeFem_BaseFlow(baseflow,'Re',40);
[ev,em] = FreeFem_Stability(baseflow,'shift',-0.015851+0.75776i,'nev',1,'type','D','STIFFNESS',1,'MASS',30,'DAMPING',0);

Re_tab = [40 : 2.5 : 80];
sigma_tab = [];
for Re = Re_tab
    baseflow=FreeFem_BaseFlow(baseflow,'Re',Re);
    [ev,em] = FreeFem_Stability(baseflow,'shift','cont','nev',1,'type','D','STIFFNESS',1,'MASS',10,'DAMPING',0);
    sigma_tab = [sigma_tab ev];
end

figure(1); hold on;
plot(Re_tab,real(sigma_tab),'r--');
title('amplification rate');

figure(2);hold on;
plot(Re_tab,imag(sigma_tab),'b--');

end
