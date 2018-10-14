% Script to compute different properties of the cylinder with CM

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;

% Mesh size
mesh.xinfm=-40.; mesh.xinfv=80.; mesh.yinf=40.0
type = 'S';
% Creation of a mesh
bf = SmartMesh(type,mesh)

% Ma = 0.5 Linear
Ma = 0.3;
Omegac = 0.718;
Rec = 47.2;

spectrumR = []; 
spectrumRNoise = []; 

spectrumI = []; 
spectrumINoise = [];    

spectrumINeg = [];   
spectrumINegNoise = [];    


imag_L = [-0.05:-0.1:-1];
nev = 10;
em_IL = [];
Ma = 0.3
realv = 0.04;
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
for imagv=imag_L(1:5)
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

realv = 0.08;
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
for imagv=imag_L(1:5)
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


realv = 0.1;
bf=SF_BaseFlow(bf,'Re',100,'Mach',Ma,'ncores',1,'type','NEW');
for imagv=imag_L(1:5)
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


for index=[170:180]
    figure();
    plotFF(em_IL(index),'ux1');
    str = [' Eigenmode with eigenvalue ',num2str(em_IL(index).lambda)];
    title(str,'Interpreter','latex');
    box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
    set(gca,'FontSize', 18);
end


save('SpectrumNegativeFurther.mat')