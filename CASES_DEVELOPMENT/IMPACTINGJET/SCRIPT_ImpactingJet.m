
run('../SOURCES_MATLAB/SF_Start.m');
close all;

figureformat='png'; FigureAspectRatio = 0.56; % for figures

if((exist('bf')==1)&&(bf.Re==200))

     disp('Adapted Mesh already available');
else
    
    disp('Creation of an adapted mesh');
    
% creation of an initial mesh
H = 2; Lpipe = 10; Rout = 120; % ,nb first case was done with Rout = 120 !
bf = SF_Init('mesh_ImpactingJet.edp',[H Lpipe Rout]);

bf.mesh.xlim=[-3,H];bf.mesh.ylim=[0,4]; % these ranges will be used for all plots
% computation of base flow with increasing Re
for Re = [10 30 60 80 100 150 200 250 300]
    bf = SF_BaseFlow(bf,'Re',Re);
  %  bf = SF_Adapt(bf);
end

% Adaptation to the structure of an eigenmode 
[ev,em] = SF_Stability(bf,'nev',1,'shift',0.005+0.i,'k',2,'type','D')
% bf = SF_Adapt(bf,em);
  
end
% a few plots
plotFF(bf,'mesh');
plotFF(bf,'ux','Contour','on','ColorMap','jet');

bf.mesh.xlim=[-10,H];bf.mesh.ylim=[0,10]; % change range to fit structure of eigenmodes
% plot the spectrum and allow to click on modes !
[ev,em] = SF_Stability(bf,'nev',10,'shift',0.01+0.i,'k',2,'PlotSpectrum','yes')



% Loop over k for stability computations
k_TAB = [0:.05:4];
k_TAB(1)=1e-8;% because k=0 won't work in this directory (something to fix in the macros)
evS_TAB = []; evA_TAB = [];
for k = k_TAB
    evA = SF_Stability(bf,'k',k,'sym','A','nev',10,'shift',0.1+0.1i,'sort','LR');
    evS = SF_Stability(bf,'k',k,'sym','S','nev',10,'shift',0.1+0.1i,'sort','LR');
    evS_TAB = [evS_TAB,evS];
    evA_TAB = [evA_TAB,evA];
end    

figure(10);
for j = 1:5
    plot(-k_TAB,real(evS_TAB(j,:)),'o-');hold on;
    plot(k_TAB,real(evA_TAB(j,:)),'o-'); hold on;
end
xlabel('|k|' ); ylabel('\lambda_r')
ylim([-0.06,0.04]);xlim([-4,4]);

figure(11);
for j = 1:5
    plot(-k_TAB,imag(evS_TAB(j,:)),'o');hold on;
    plot(k_TAB,imag(evA_TAB(j,:)),'o'); hold on;
end
xlabel('|k|' ); ylabel('\lambda_i')
ylim([-.2,.2]);xlim([-4,4]);


