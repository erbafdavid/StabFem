% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  Demonstration script for the test-case of a cylindrical object in a tube
%
% Version 2.0 by D. Fabre , june 2017

clear all;
close all;
clc;

run('../SOURCES_MATLAB/SF_Start.m');

%ffdatadir = './WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational


% 
Re = 200;
if(exist([ ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'])==2)
     disp(['base flow and adapted mesh for Re = ' num2str(Re) ' already computed']);
    if (exist('bf')==0); % if the data are present but the variables were cleared
    mesh=importFFmesh('mesh.msh');
    bf =importFFdata(mesh,[ ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.ff2m']);
    end
    
else
    disp('computing base flow and adapting mesh');
    bf = SF_Init('meshInit_DiskInTube.edp'); 
    Re_start = [10 , 100 , 200]; % values of Re for progressive increasing up to end
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei); 
        bf=SF_Adapt(bf);
    end
    
 % optional : adapting mesh on eigenmode structure as well      
 [ev,eigenmode] = SF_Stability(bf,'m',1,'shift',0.021+1.771i,'nev',1,'type','S');
 [bf,eigenmode]=SF_Adapt(bf,eigenmode);  
 [bf,eigenmode]=SF_Adapt(bf,eigenmode); 



%mesh = importFFmesh([ffdatadir 'mesh.msh'],'seg'); 
plotFF(bf,'mesh'); % to plot the mesh

bf.mesh.xlim=[-1,3]; %x-range for plots
bf.mesh.ylim=[0,1];
plotFF(bf,'ux');  % to plot the bf

end

tit = 1;

while(tit~=0)

disp('Type of computation required : ')
disp('   1 -> spectrum and exploration of eigenmodes for a given Re and m');
disp('   2 -> stability curves for a range of Re' );
disp('   3 -> mode + adjoint + sensitivity');
disp('   4 -> base flow Drag as function of Re'); 
disp('   5 -> coefficients of amplitude equation from weakly nonlinear analysis'); 
disp('   0 -> exit');
tit=myinput(' choice ?',1); 

switch tit
    case(1)
        % To plot spectrum and allow to click on modes to plot eigenmodes
   SF_Spectrum_Exploration(bf);

    case(2)
    disp('Computing stability branches in the range Re = [120-220] for the fist two branches');
    % stability calculations with loop over Re

    % Unsteady mode branch
    if(exist('EVI')==0) 
        Re_RangeI = [170:10:220];EVI = [];
        guessI = 1.85i-.1;
        bf=SF_BaseFlow(bf,'Re',170);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI,'nev',1,'type','D');
        for Re = Re_RangeI
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI = [EVI ev];
        end  
        
        
    else
%        data = importata(
    end
    % Steady mode branch
    if(exist('EVS')==0)
        guessS = -.1;
        Re_RangeS = [120:10:180];EVS = [];
       % EVS = SF_Stability_LoopRe(bf,Re_RangeS,'m',1,'shift',guessS,'nev',1);
        
        bf=SF_BaseFlow(bf,'Re',120);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessS,'nev',1,'type','D');
        for Re = Re_RangeS
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVS = [EVS ev];
        end
        
    end
    figure(11);
    subplot(2,1,1);hold on;
    plot(Re_RangeS,real(EVS),'-*b',Re_RangeI,real(EVI),'-*r')
    title('growth rate Re(sigma) vs. Reynolds ; unstready mode (red) and steady mode (blue)')
    subplot(2,1,2);hold on;
    plot(Re_RangeS,imag(EVS),'-*b',Re_RangeI,imag(EVI),'-*r')
    title('oscillation rate Im(sigma) vs. Reynolds')

 case(3)
    disp(['adjoint and structural sensitivity']);
    Re = myinput('Enter Reynolds number : ',200);  
    m = myinput('Enter wavenumber m : ',1);  
    shift = myinput('Enter shift (complex)  : ',0.03+1.78i);
    bf = SF_BaseFlow(bf,'Re',Re);
    bf.mesh.xlim=[-1 3]; % xrange fixed in bf.mesh ; inherited by modes
    
    
    [ev,eigenmode]=SF_Stability(bf,'m',m,'shift',shift,'nev',1,'type','S');
    
    eigenmode.plottitle=['Direct eigenmode with lambda = ',num2str(eigenmode.lambda)]; 
    plotFF(eigenmode,'ux1');
    
    eigenmode.plottitle=['Adjoint eigenmode with lambda = ',num2str(eigenmode.lambda)]; 
    plotFF(eigenmode,'ux1Adj');
    
    eigenmode.plottitle=['Structural sensitivity with lambda = ',num2str(eigenmode.lambda)]; 
    plotFF(eigenmode,'sensitivity');
     
    
    case(4)

    % base flow characteristics with loop over Re
    Re_Range = [120:10:220];

    if(exist('Cx_branch')==0)% to save time if already computed
    Cx_branch = [];
    for Re = Re_Range
        bf=SF_BaseFlow(bf,'Re',Re);
        Cx_branch = [Cx_branch,bf.Cx];
    end
    end
    
    figure(12);
    plot(Re_Range,Cx_branch);
    xlabel('Re');
    ylabel('Cx');
    title('Base flow Drag coefficient as function of Re');
    
    
    
    
     case(5)
        Rec = 133.32;
        m = 1;
        disp('Computing coefficients of the weakly nonlinear amplitude equation');
        disp('NB : at the moment this will work only for steady, m=1 bifurcation');
        disp(['Rec = ', num2str(Rec)]);
        bf=SF_BaseFlow(bf,'Re',Rec);
 %       [evD,eigenmodeD]=SF_Stability(bf,'m',m,'shift',0,'nev',1);
 %       eigenmodeD
        [ev,eigenmode]=SF_Stability(bf,'m',m,'shift',0,'type','S','nev',1);
%        eigenmodeA
        wnl = SF_WNL(bf,eigenmodeD)
        
    % plot 'linear' parts of the results on the drag/re and sigma/re curves
        
        ReWa = [Rec-20 Rec+20]; 
        DWa  = 8/pi*(wnl.Drag0+wnl.Drageps/Rec^2*(ReWa-Rec));
        ReWb = Rec+ [0 :0.01 :1].^2*30; 
        DWb  = 8/pi*(wnl.Drag0+(wnl.Drageps+real(wnl.DragAAs*wnl.lambdaA/wnl.muA))/Rec^2*(ReWb-Rec));
        figure(12);hold on;
        plot(ReWa,DWa,'--b',ReWb,DWb,'--r',Rec,8/pi*wnl.Drag0,'ro');
         
        EVSW = wnl.eigenvalue+wnl.lambdaA/Rec^2*(ReWa-Rec);
        figure(11);subplot(2,1,1);
        hold on;
        plot(ReWa,real(EVSW),'--');
        plot(Rec,0,'ro');
        
        figure(13);
        % we try epsilon and epsilonprime (cf. Gallaire et al, FDR 2017, and Tchoufag et al.)
        LiftA_epsilon = sqrt(abs(wnl.lambdaA/wnl.muA).*(1/Rec-1./ReWb)); 
        LiftA_epsilonprime = sqrt(abs(wnl.lambdaA/wnl.muA).*(ReWb-Rec)/Rec^2);
        plot(ReWb,LiftA_epsilon,'b-',ReWb,LiftA_epsilonprime,'b--');
       title('Lift force as function of Re (WNL expansions ; epsilon and epsilon'' scalings)');
        
        
    case(0)
    disp('Goodbye ! hope you had fun :)');
end %switch

end %while

%TRUCS A REGLER
% adaptmesh on adjoint
% reglage des iso niveaux
