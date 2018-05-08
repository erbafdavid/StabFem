
run('../SOURCES_MATLAB/SF_Start.m');
close all;
%ffdatadir = './WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational

Rbody = 1; Lbody = 5;Rpipe = 1.5; xmin = -10; xmax = 30;

    disp('computing base flow and adapting mesh');
    bf = SF_Init('meshInit_BluntBodyInTube.edp',[Rbody Rpipe Lbody xmin xmax]); 
    Re_start = [10 , 30, 60, 100 , 200]; % values of Re for progressive increasing up to end
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei); 
        bf=SF_Adapt(bf,'Hmax',0.5);
    end
 
 shift =    0.15+1.098i; % shift for steady mode
% compute a spectrum   
 [ev,eigenmode] = SF_Stability(bf,'m',1,'shift',shift,'nev',10,'type','D','plotspectrum','yes');   
pause(0.1);
 shift = ev(1);
 
 
 % optional : adapting mesh on eigenmode structure as well      
 [ev,eigenmode] = SF_Stability(bf,'m',1,'shift',shift,'nev',1,'type','S');
 [bf,eigenmode]= SF_Adapt(bf,eigenmode);  
 
% range for figures
bf.mesh.xlim=[-2*Rbody,Lbody+5*Rbody]; %x-range for plots
bf.mesh.ylim=[0,Rpipe];

plotFF(bf,'mesh'); % to plot the mesh
bf.mesh.xlim=[-2*Rbody,Lbody+5*Rbody]; %x-range for plots
bf.mesh.ylim=[0,Rpipe];
plotFF(bf,'ux');  % to plot the bf
pause(0.1);

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
    Re_RangeI = [200:-10:100];EVI = [];
        guessI = 1.09i+0.157;
        bf=SF_BaseFlow(bf,'Re',200);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI,'nev',1,'type','D');
        for Re = Re_RangeI
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI = [EVI ev];
        end  
        
%% COMPUTING THE STEADY BRANCH (going backwards)
    Re_RangeS = [200:-10:100];EVS = [];
        guessS = 0.319;
        bf=SF_BaseFlow(bf,'Re',200);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessS,'nev',1,'type','D');
        for Re = Re_RangeS
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVS = [EVS ev];
        end  
        

 figure(11);
    subplot(2,1,1);hold on;
    plot(Re_RangeS,real(EVS),'-*b',Re_RangeI,real(EVI),'-*r')
    title('growth rate Re(sigma) vs. Reynolds ; unstready mode (red) and steady mode (blue)')
    subplot(2,1,2);hold on;
    plot(Re_RangeS,imag(EVS),'-*b',Re_RangeI,imag(EVI),'-*r')
    title('oscillation rate Im(sigma) vs. Reynolds')





