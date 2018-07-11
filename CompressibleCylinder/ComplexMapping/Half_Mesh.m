%TODO ADD symmetries in Macros_StabFEM and do a script file to write
%mysystem 
% Sensitivity has issues with symmetry

% CHAPTER 0 : set the global variables needed by the drivers

clear all;
% close all;
run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;



% parameters for mesh creation 
% Outer Domain 
xinfm=-35.; xinfv=70.; yinf=35;
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=40.;y2=10;
% Sponge extension
ls=0.1; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=80; % Refinement density around the cylinder
n1=8; % Density in the inner domain
n2=3; % Density in the middle domain
ns=0.2; % Density in the outer domain
nsponge=.2; % density in the sponge region
alpha = 0.0;
method = 'CM';
symm = 1;
symmEig = 0;
% 1 if the mesh is created in matlab, 0 otherwise.

mysystem(['echo "xinfm= ' num2str(xinfm) '; xinfv= ' num2str(xinfv) ...
          '; yinf= ' num2str(yinf) ';" > SF_Mesh.edp']); 
mysystem(['echo "alpha= ' num2str(alpha) '; method= \"' method ...
    '\"; symmetryBaseFlow= ' num2str(symm)...
    '; symmetryEigenmode= ' num2str(symmEig) ';" > SF_Method.edp']);

%Compressibility to create a mesh 
Ma = 0.1


disp(' '); 
disp(' STARTING ADAPTMESH PROCEDURE : ');    
disp(' ');

if(exist('mesh_completed')==1)
disp(' ADAPTMESH PROCEDURE AS PREVIOUSLY DONE, START WITH EXISTING MESH : '); 
bf=SF_BaseFlow(bf,'Re',47,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',0.001 + 0.732i,'nev',1,'type','D','sym','N','Ma',Ma);
else
bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',1,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',4);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',4);
bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',4);
[ev,em] = SF_Stability(bf,'shift',0.041 + 0.735i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',3);
[ev,em] = SF_Stability(bf,'shift',0.041 + 0.735i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',3);
% [ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
% [bf,em]=SF_Adapt(bf,em,'Hmax',4);

mesh_completed = 1;
end

% plot the mesh (full size)
figure(30)
plotFF(bf,'mesh');
title('Initial mesh (full size)');
box on; %pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh_Full',figureformat); 

% plot the mesh (zoom)
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'mesh');
title('Initial mesh (zoom)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh',figureformat);
    
% plot the base flow for Re = 60
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(meanflow,'ux','Contour','on','Levels',[0 0]);
%plotFF(bf,'ux');
title('Base flow at Re=60 (axial velocity)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_BaseFlowRe60',figureformat);

figure(26)
% plot the eigenmode for Re = 60
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1');
title('Eigenmode for Re=60');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_EigenModeRe60_AdaptS',figureformat);  %





if(exist('Rec')==1)
    disp('INSTABILITY THRESHOLD ALREADY COMPUTED');
    bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
    [ev,em] = SF_Stability(bf,'shift',em.lambda,'type','S','nev',1,'sym','A','Ma',Ma);
else 
%%% DETERMINATION OF THE INSTABILITY THRESHOLD
disp('COMPUTING INSTABILITY THRESHOLD');
bf=SF_BaseFlow(bf,'Re',48,'Ma',Ma);
[ev,em] = SF_Stability(bf,'shift',+.738i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_FindThreshold(bf,em);
Rec = bf.Re;  Fxc = bf.Fx; 
Lxc=bf.Lx;    Omegac=imag(em.lambda);
%[ev,em] = SF_Stability(bf,'shift',em.lambda,'type','S','nev',1);
end



Omegac = 0.728
Rec = 47
bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',1,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',5);
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);


% plot the base flow for Re = 60
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'ux','Contour','on','Levels',[0 0]);
%plotFF(bf,'ux');
title('Base flow at Re=60 (axial velocity)');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_BaseFlowRe60',figureformat);



[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','A','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.3,'Normalization','L'); % Here to generate a starting point for the next chapter

%%% PLOTS of WNL predictions

epsilon2_WNL = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL = 1./(1/Rec-epsilon2_WNL);
A_WNL = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

Re_HB = [Rec 47.3 47.7 48 48.5 49 49.5 50 51 52.0 53 54 55 56 57 58 59 60];
Re_HBp = (61:1.5:100)
Re_HB = [Re_HB, Re_HBp]

%%% THE STARTING POINT HAS BEEN GENERATED ABOVE, WHEN PERFORMING THE WNL
%%% ANALYSIS
Res = 47.3 ; 
Lx_HB = [0]; Fx_HB = [Fx_WNL]; omega_HB = [Omegac]; Aenergy_HB  = [0]; Fy_HB = [Fy_WNL];

for Re = Re_HB(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',Re);
    Lx_HB = [Lx_HB meanflow.Lx];
    Fx_HB = [Fx_HB meanflow.Fx];
    omega_HB = [omega_HB imag(mode.lambda)];
    Aenergy_HB  = [Aenergy_HB mode.AEnergy];
    Fy_HB = [Fy_HB mode.Fy];
    
    if(Re==60)
       meanflow.xlim = [-2 4]; meanflow.ylim=[0,3];
       plotFF(meanflow,'ux','contour','on','levels',[0 0]);
%       plotFF(meanflow,'ux');
       title('Mean flow at Re=60 (axial velocity)');
       box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
       set(gca,'FontSize', 18);
       saveas(gca,'Cylinder_MeanFlowRe60',figureformat); 
    end
    save('Results_SC.mat');

end


% Ma = 0.2 Nonlinear analysis
Ma = 0.2
Omegac = 0.725
Rec = 47.0

bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',1,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',6);
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);


bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','A','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.3,'Normalization','L'); % Here to generate a starting point for the next chapter

%%% PLOTS of WNL predictions

epsilon2_WNL_M2  = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL_M2  = 1./(1/Rec-epsilon2_WNL);
A_WNL_M2  = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL_M2  = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL_M2  =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL_M2  = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

Lx_HB_M2 = [0]; Fx_HB_M2  = [Fx_WNL_M2 ]; omega_HB_M2 = [Omegac];
Aenergy_HB_M2   = [0]; Fy_HB_M2  = [Fy_WNL_M2 ];

for Re = Re_HB(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',Re);
    Lx_HB_M2  = [Lx_HB_M2  meanflow.Lx];
    Fx_HB_M2  = [Fx_HB_M2  meanflow.Fx];
    omega_HB_M2  = [omega_HB_M2  imag(mode.lambda)];
    Aenergy_HB_M2   = [Aenergy_HB_M2  mode.AEnergy];
    Fy_HB_M2  = [Fy_HB_M2  mode.Fy];
    save('Results_SC.mat');

end
mysystem('rm WORK/SelfConsistentMode.txt');
mysystem('rm WORK/MeanFlow.txt');

% Ma = 0.3 Nonlinear analysis
Ma = 0.3
Omegac = 0.7185
Rec = 47.3

Re_HB_M3 = Re_HB
Re_HB_M3(2) = 47.6

bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','A','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.6,'Normalization','L'); % Here to generate a starting point for the next chapter

%%% PLOTS of WNL predictions

epsilon2_WNL_M3  = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL_M3  = 1./(1/Rec-epsilon2_WNL);
A_WNL_M3  = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL_M3  = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL_M3  =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL_M3  = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

Lx_HB_M3 = [0]; Fx_HB_M3  = [Fx_WNL_M3 ]; omega_HB_M3 = [Omegac];
Aenergy_HB_M3   = [0]; Fy_HB_M3  = [Fy_WNL_M3 ];

for Re = Re_HB_M3(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',Re);
    Lx_HB_M3  = [Lx_HB_M3  meanflow.Lx];
    Fx_HB_M3  = [Fx_HB_M3  meanflow.Fx];
    omega_HB_M3  = [omega_HB_M3  imag(mode.lambda)];
    Aenergy_HB_M3   = [Aenergy_HB_M3  mode.AEnergy];
    Fy_HB_M3  = [Fy_HB_M3  mode.Fy];
    save('Results_SC.mat');

end
mysystem('rm WORK/SelfConsistentMode.txt');
mysystem('rm WORK/MeanFlow.txt');

% Ma = 0.4 Nonlinear analysis
Ma = 0.4
Omegac = 0.7085
Rec = 47.9
Re_HB_M4 = Re_HB
Re_HB_M4(2) = 48.15
Re_HB_M4(3) = 48.3
Re_HB_M4(4) = 48.5
Re_HB_M4(5) = 48.7

bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',1,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',0.09+ 0.66*i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',6);

bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','A','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',48.15,'Normalization','L'); % Here to generate a starting point for the next chapter

%%% PLOTS of WNL predictions

epsilon2_WNL_M4  = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL_M4  = 1./(1/Rec-epsilon2_WNL);
A_WNL_M4  = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL_M4  = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL_M4  =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL_M4  = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

Lx_HB_M4 = [0]; Fx_HB_M4  = [Fx_WNL_M4 ]; omega_HB_M4 = [Omegac];
Aenergy_HB_M4   = [0]; Fy_HB_M4  = [Fy_WNL_M4 ];

for Re = Re_HB_M4(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',Re);
    Lx_HB_M4  = [Lx_HB_M4  meanflow.Lx];
    Fx_HB_M4  = [Fx_HB_M4  meanflow.Fx];
    omega_HB_M4  = [omega_HB_M4  imag(mode.lambda)];
    Aenergy_HB_M4   = [Aenergy_HB_M4  mode.AEnergy];
    Fy_HB_M4  = [Fy_HB_M4  mode.Fy];
    save('Results_SC.mat');

end
mysystem('rm WORK/SelfConsistentMode.txt');
mysystem('rm WORK/MeanFlow.txt');

% Ma = 0.5 Nonlinear analysis
Ma = 0.5
Omegac = 0.6945
Rec = 49.15
Re_HB_M5 = Re_HB
Re_HB_M5(2) = 49.35
Re_HB_M5(3) = 49.6
Re_HB_M5(4) = 49.9
Re_HB_M5(5) = 50.2
Re_HB_M5(6) = 50.5
Re_HB_M5(7) = 50.8
Re_HB_M5(8) = 51.1
Re_HB_M5(9) = 51.4

bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',1,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',150,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(bf,'Hmax',6);
[ev,em] = SF_Stability(bf,'shift',0.15+ 0.640*i,'nev',1,'type','D','sym','A','Ma',Ma);
[bf,em]=SF_Adapt(bf,em,'Hmax',6);
bf=SF_BaseFlow(bf,'Re',150,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',0.15+ 0.640*i,'nev',1,'type','D','sym','A','Ma',Ma);


bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','A','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',49.35,'Normalization','L'); % Here to generate a starting point for the next chapter

%%% PLOTS of WNL predictions

epsilon2_WNL_M5  = -0.003:.0001:.005; % will trace results for Re = 40-55 approx.
Re_WNL_M5  = 1./(1/Rec-epsilon2_WNL);
A_WNL_M5  = wnl.Aeps*real(sqrt(epsilon2_WNL));
Fy_WNL_M5  = wnl.Fyeps*real(sqrt(epsilon2_WNL))*2; % factor 2 because of complex conjugate
omega_WNL_M5  =Omegac + epsilon2_WNL*imag(wnl.Lambda) ...
                  - epsilon2_WNL.*(epsilon2_WNL>0)*real(wnl.Lambda)*imag(wnl.nu0+wnl.nu2)/real(wnl.nu0+wnl.nu2)  ;
Fx_WNL_M5  = wnl.Fx0 + wnl.Fxeps2*epsilon2_WNL  ...
                 + wnl.FxA20*real(wnl.Lambda)/real(wnl.nu0+wnl.nu2)*epsilon2_WNL.*(epsilon2_WNL>0) ;

Lx_HB_M5 = [0]; Fx_HB_M5  = [Fx_WNL_M5 ]; omega_HB_M5 = [Omegac];
Aenergy_HB_M5   = [0]; Fy_HB_M5  = [Fy_WNL_M5 ];

for Re = Re_HB_M5(2:end)
    [meanflow,mode] = SF_SelfConsistentDirect(meanflow,mode,'Re',Re);
    Lx_HB_M5  = [Lx_HB_M5  meanflow.Lx];
    Fx_HB_M5  = [Fx_HB_M5  meanflow.Fx];
    omega_HB_M5  = [omega_HB_M5  imag(mode.lambda)];
    Aenergy_HB_M5   = [Aenergy_HB_M5  mode.AEnergy];
    Fy_HB_M5  = [Fy_HB_M5  mode.Fy];
    save('Results_SC.mat');

end





