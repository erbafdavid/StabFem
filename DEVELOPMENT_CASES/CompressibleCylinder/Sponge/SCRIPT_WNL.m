
clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;


% parameters for mesh creation 
% Outer Domain 
xinfm=-40.; xinfv=80.; yinf=40.;
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=30.;y2=10;
% Sponge extension
ls=300.0; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=100; % Refinement density around the cylinder
n1=7; % Density in the inner domain
n2=3; % Density in the middle domain
ns=0.15; % Density in the outer domain
nsponge=.15; % density in the sponge region

%Compressibility to create a mesh 
Ma = 0.1


disp(' '); 
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');


%%% 1st WNL with M1
bf = SF_Init('Mesh.edp',[xinfm,xinfv,yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
bf=SF_BaseFlow(bf,'Re',47,'Ma',Ma);
[ev,em] = SF_Stability(bf,'shift',+.729i,'nev',1,'type','D','sym','N','Ma',Ma);
[bf,em]=SF_FindThreshold(bf,em);
Rec = bf.Re;  Fxc = bf.Fx; 
Lxc=bf.Lx;    Omegac=imag(em.lambda);
%[ev,em] = SF_Stability(bf,'shift',em.lambda,'type','S','nev',1);
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','N','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.1,'Normalization','V'); % Here to generate a starting point for the next chapter
save('Results_Cylinder.mat');

%%% PLOTS of WNL predictions

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

figure(20);hold on;
plot(Re_WNL,real(wnl.Lambda)*epsilon2_WNL,'g--','LineWidth',2);hold on;

figure(21);hold on;
plot(Re_WNL,omega_WNL/(2*pi),'g--','LineWidth',2);hold on;
xlabel('Re');ylabel('St');

figure(22);hold on;
plot(Re_WNL,Fx_WNL,'g--','LineWidth',2);hold on;
xlabel('Re');ylabel('Fx');

figure(24); hold on;
plot(Re_WNL,abs(Fy_WNL),'g--','LineWidth',2);
xlabel('Re');ylabel('Fy')

figure(25);hold on;
plot(Re_WNL,A_WNL,'g--','LineWidth',2);
xlabel('Re');ylabel('AE')

pause(0.1);