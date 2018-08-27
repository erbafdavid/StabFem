
clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;


% parameters for mesh creation 
% Outer Domain 
xinfm=-50.; xinfv=100.; yinf=50.;
% Middle domain
x1m=-5.; x1v=30.; y1=2.5;
% Inner domain
x2m=-15.;x2v=50.;y2=10;
% Sponge extension
ls=300; 
% Refinement parameters
n=2; % Vertical density of the outer domain
ncil=90; % Refinement density around the cylinder
n1=7.5; % Density in the inner domain
n2=3.75; % Density in the middle domain
ns=1.5; % Density in the outer domain
nsponge=0.15; % density in the sponge region
% 1 if the mesh is created in matlab, 0 otherwise.

bf = SF_Init('Mesh.edp',[-21,81,21,-5,15,2.5,-20,80,20,600,n,ncil,n1,n2,ns,nsponge]);

spectrumI = []; 
imag_L = [0.1:0.1:1.2];
nev = 10;
em_IL = [];
Ma = 0.3
Re = 100.0
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
realv = 0.1;

% Compute imaginary axis
for imagv=imag_L(1:end)
        if(imagv < 0.4 || imagv > 0.75)
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
%             else
%                 spectrumINoise = [spectrumINoise evD];
%                 em_ILNoise =  [em_ILNoise emD];

            %end
        end
end


save('SpectrumFull.mat')


sizeI = size(spectrumI);
sizeI = sizeI(2);
figure();hold on;
for j=[1:sizeI]
    plot(real(spectrumI(:,j)),imag(spectrumI(:,j)),'o','LineWidth',2);hold on;
    box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
end

for index=[91:100]
    figure();
    plotFF(em_IL(index),'ux1');
    str = [' Eigenmode with eigenvalue ',num2str(em_IL(index).lambda)];
    title(str,'Interpreter','latex');
    box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
    set(gca,'FontSize', 18);
end

figure()
plotFF(bf,'mesh');
save('SpectrumFull.mat')