% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  Demonstration script for the test-case of a cylindrical object in a tube
%
% Version 2.0 by D. Fabre , june 2017


%close all;
global ff ffdir ffdatadir sfdir 
ff = '/usr/local/bin/FreeFem++-nw -v 0'; %% Freefem command with full path 
ffdatadir = './DATA_FREEFEM_DISKINTUBE';
sfdir = '../SOURCES_MATLAB'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts

addpath(sfdir);

% 
Re = 200;
if(exist([ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'])==2)
    disp(['base flow and adapted mesh for Re = ' num2str(Re) ' already computed']);
else
    disp('computing base flow and adapting mesh')
   
    baseflow = FreeFem_Init('meshInit_DiskInTube.edp') 
    Re_start = [10 , 100 , 200]; % values of Re for progressive increasing up to end
    for Rei = Re_start
        baseflow=FreeFem_BaseFlow(baseflow,Rei) 
        baseflow=FreeFem_Adapt(baseflow)
    end
    
 % optional : adapting mesh on eigenmode structure as well      
 [ev,eigenmode] = FreeFem_Stability(baseflow,200,1,0.021+1.771i,1)
 [baseflow,eigenmode]=FreeFem_Adapt(baseflow,eigenmode);  
 
baseflow.mesh.xlim=[-1,3]; %x-range for plots
plotFF(baseflow,'mesh');
plotFF(baseflow,'u0');  

end

tit = 1;

while(tit~=0)

disp('Type of computation required : ')
disp('   1 -> spectrum and exploration of eigenmodes for a given Re and m');
disp('   2 -> stability curves for a range of Re' );
disp('   3 -> mode + adjoint + sensitivity');
disp('   4 -> coefficients of amplitude equation from weakly nonlinear analysis'); 
disp('   5 -> base flow Drag as function of Re'); 
disp('   0 -> exit');
tit=myinput(' choice ?',1); 

switch tit
    case(1)
        % To plot spectrum and allow to click on modes to plot eigenmodes
   FreeFem_Spectrum_Exploration(baseflow);

    case(2)
    disp('Computing stability branches in the range Re = [120-220] for the fist two branches');
    % stability calculations with loop over Re
    Re_Range = [120:10:220];

    % Unsteady mode branch
    if(exist('EVI')==0)
        EVI = FreeFem_Stability_LoopRe(baseflow,Re_Range,1,-.43+2.06i,1);
    end
    % Steady mode branch
    if(exist('EVS')==0)
        EVS = FreeFem_Stability_LoopRe(baseflow,Re_Range,1,-0.123,1);
    end
    figure;
    subplot(2,1,1);
    plot(Re_Range,real(EVS),'-*b',Re_Range,real(EVI),'-*r')
    title('growth rate Re(sigma) vs. Reynolds ; unstready mode (red) and steady mode (blue)')
    subplot(2,1,2);
    plot(Re_Range,imag(EVS),'-*b',Re_Range,imag(EVI),'-*r')
    title('oscillation rate Im(sigma) vs. Reynolds')

 case(3)
    disp(['adjoint and structural sensitivity']);
    Re = myinput('Enter Reynolds number : ',200);  
    m = myinput('Enter wavenumber m : ',1);  
    shift = myinput('Enter shift (complex)  : ',0.03+1.78i);
    baseflow = FreeFem_BaseFlow(baseflow,Re);
    baseflow.mesh.xlim=[-1 3]; % xrange fixed in baseflow.mesh ; inherited by modes
    
    if(exist('eigenmode')==0)
        [ev,eigenmode]=FreeFem_Stability(baseflow,Re,m,shift,1);
    end
    eigenmode.plottitle=['Direct eigenmode with sigma = ',num2str(eigenmode.sigma)]; 
    plotFF(eigenmode,'ux1',1);
    
    if(exist('eigenmodeA')==0)
        [evA,eigenmodeA]=FreeFem_Stability(baseflow,Re,m,shift,1,'A');
    end
    eigenmodeA.plottitle=['Adjoint eigenmode with sigma = ',num2str(eigenmodeA.sigma)]; 
    plotFF(eigenmodeA,'ux1',1);
    
    wavemaker.mesh = eigenmode.mesh;
    wavemaker.plottitle = 'structural sensitivity';
    wavemaker.xlim = [-1,3];
    wavemaker.sensitivity=abs(eigenmode.ux1).*abs(eigenmodeA.ux1)+abs(eigenmode.ur1).*abs(eigenmodeA.ur1)+abs(eigenmode.ut1).*abs(eigenmodeA.ut1);
    plotFF(wavemaker,'sensitivity');
    
     case(4)
        Rec = 133.28;
        m = 1;
        disp('Computing coefficients of the weakly nonlinear amplitude equation');
        disp('NB : at the moment this will work only for steady, m=1 bifurcation');
        disp(['Rec = ', num2str(Rec)]);
        baseflow=FreeFem_BaseFlow(baseflow,Rec);
        [evD,eigenmodeD]=FreeFem_Stability(baseflow,Rec,m,0,1);
        eigenmodeD
        [evA,eigenmodeA]=FreeFem_Stability(baseflow,Rec,m,0,1,'A');
        eigenmodeA
        wnl_coeffs = FreeFem_WNL(baseflow)
            
     case(5)

    % base flow characteristics with loop over Re
    Re_Range = [120:10:220];

    if(exist('Drag_branch')==0)% to save time if already computed
    Drag_branch = [];
    for Re = Re_Range
        baseflow=FreeFem_BaseFlow(baseflow,Re);
        Drag_branch = [Drag_branch,baseflow.Drag];
    end
    end
    
    figure();
    plot(Re_Range,Drag_branch);
    title('base flow drag as function of Re');
    
    
    case(0)
    disp('Goodbye ! hope you had fun :)');
end %switch

end %while

%TRUCS A REGLER
% adaptmesh on adjoint
% reglage des iso niveaux
