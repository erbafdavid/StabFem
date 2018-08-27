% Script to compute different properties of the cylinder with CM

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;


% parameters for mesh creation 
% Outer Domain 
mesh.xinfm=-40.; mesh.xinfv=100.; mesh.yinf=40.0
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=30.;y2=10;
% Sponge extension
ls=0.01; 
% Refinement parameters
n=1.8; % Vertical density of the outer domain
ncil=70; % Refinement density around the cylinder
n1=4; % Density in the inner domain
n2=2; % Density in the middle domain
ns=0.15; % Density in the outer domain
nsponge=.1; % density in the sponge region

% parameters for mesh creation 
% This parameter is used if sponge is selected
method.alpha = 0.0;
% Either Complex mapping (CM) or Sponge (S)
method.name = 'CM';
% symmetric (1) or full domain (2)
method.symm = 2;
% 0 indicates antisymmetry for the mode, 1 symmetry, 2 full domain
method.symmEig = 2;
% Coefficients of the complex mapping, to determine La, Lc and gammac for 
% each mapping (negative x-Xn, postive x-Xp and positive y-Yp)
% Compute mesh without complex mapping
CM.BoxXpCoeff = 1.2;
CM.BoxXnCoeff = -1.3;
CM.BoxYpCoeff = 1.15;
CM.LaXpCoeff = 1.01;
CM.LaXnCoeff = 1.01;
CM.LaYpCoeff = 1.01;
CM.LcXpCoeff = 0.4;
CM.LcXnCoeff = 0.5;
CM.LcYpCoeff = 0.35;
CM.gcXpCoeff = 0.0;
CM.gcXnCoeff = 1.0;
CM.gcYpCoeff = 0.0;

myWriteMethod(CM,mesh,method);

% Ma = 0.5 Linear
Ma = 0.3;
Omegac = 0.718;
Rec = 47.2;
MeshBased = 'D'; % Used for mesh refinement
meshRef = 1.5
% Mesh generation
bf = SF_Init('Mesh.edp',[mesh.xinfm,mesh.xinfv,mesh.yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',meshRef);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_AdaptMesh(bf,'Hmax',meshRef);
if (MeshBased == 'S')
    bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
    [evD,emD] = SF_Stability(bf,'shift',Omegac*i,'nev',1,'type','S','sym','A','Ma',Ma);
    emD.filename='./WORK/Sensitivity.txt';
    emD.datastoragemode='ReP2';
    bf=SF_AdaptMesh(bf,emD,'Hmax',meshRef);
    bf=SF_BaseFlow(bf,'Re',60,'Mach',Ma,'ncores',1,'type','NEW');
    [evD,emD] = SF_Stability(bf,'shift',0.046 + 0.745i,'nev',1,'type','S','sym','A','Ma',Ma);
    emD.filename='./WORK/Sensitivity.txt';
    emD.datastoragemode='ReP2';
    bf=SF_AdaptMesh(bf,emD,'Hmax',meshRef);
    [evD,emD] = SF_Stability(bf,'shift',0.046 + 0.745i,'nev',1,'type','D','sym','A','Ma',Ma);
else
   [evCr,emCr] = SF_Stability(bf,'shift',0.7*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
   [evD,emD] = SF_Stability(bf,'shift',0.11+0.685*1i,'nev',1,'type','D','sym','A','Ma',Ma);
   bf=SF_AdaptMesh(bf,emD,emCr,'Hmax',meshRef);
end

Ma = 0.3;
CM.BoxXpCoeff = 0.5;
CM.BoxXnCoeff = -0.4;
CM.BoxYpCoeff = 0.4;
CM.LaXpCoeff = 1.345;
CM.LaXnCoeff = 1.84;
CM.LaYpCoeff = 1.84;
CM.LcXpCoeff = 0.3;
CM.LcXnCoeff = 0.3;
CM.LcYpCoeff = 0.3;
CM.gcXpCoeff = -0.3;
CM.gcXnCoeff = -0.1;
CM.gcYpCoeff = -0.1;
myWriteMethod(CM,mesh,method);

spectrumR = []; 
spectrumRNoise = []; 

spectrumI = []; 
spectrumINoise = [];    

spectrumINeg = [];   
spectrumINegNoise = [];    


imag_L = [0.05:0.1:1];
nev = 10;
em_IL = [];
Ma = 0.3
realv = 0.1;
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
for imagv=imag_L(1:end)
        if(imagv < 0.4)
            realv = 0.01
        else
            realv = 0.1
        end
        lambda = realv + imagv*1i;
        [ev,em] = SF_Stability(bf,'shift',lambda,'nev',nev,'sym','N','Ma',Ma);
        for j=[1:nev]
            %[evD,emD] = SF_Stability(bf,'shift',ev(j),'nev',1,'sym','N','Ma',Ma); % Validate eigenvalues computed with SLEPc
            evD = ev(j);
            emD = em(j);
            mycp( emD.filename, [' ./WORK/Eigenmodes/Eigenmode',num2str(imagv),num2str(j),'.txt']);
            mycp( ['.WORK/Eigenmode',num2str(j),'.ff2m'], [' ./WORK/Eigenmodes/Eigenmode',num2str(imagv),num2str(j),'.txt']);
            emD.fileSave = [' ./WORK/Eigenmodes/Eigenmode',num2str(imagv),num2str(j),'.txt'];
            emD.fileFF2M = [' ./WORK/Eigenmodes/Eigenmode',num2str(imagv),num2str(j),'.ff2m']
%             if( abs(evD-ev(j)) < 1e-6 ) % Both approaches should give the same eigenvalue
            spectrumI = [spectrumI evD];
            em_IL = [em_IL emD];
        end
end

sizeI = size(spectrumI);
sizeI = sizeI(2);
figure();hold on;
for j=[1:sizeI]
    plot(real(spectrumI(:,j)),imag(spectrumI(:,j)),'o','LineWidth',2);hold on;
    box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
end

figure();
plotFF(em,'ux1');

for index=[1:10]
    figure();
    plotFF(em_IL(index),'ux1');
    str = [' Eigenmode with eigenvalue ',num2str(em_IL(index).lambda)];
    title(str,'Interpreter','latex');
    box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
    set(gca,'FontSize', 18);
end


save('Spectrum.mat')