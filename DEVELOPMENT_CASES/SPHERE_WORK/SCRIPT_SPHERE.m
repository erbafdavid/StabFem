% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  Demonstration script for the test-case of a SPHERE
%
% Version 2.0 by D. Fabre , june 2017

close all;
clear all;
global ff ffdir ffdatadir
ff = '/usr/local/bin/FreeFem++-nw -v 0'; %% Freefem command with full path 
ffdir = './SOURCES_FREEFEM/'; % where to find the freefem scripts
ffdatadir = './DATA_FREEFEM_SPHERE';

% 

    disp(' ');disp('### '); disp('### CHAPTER 0 : ');disp('### ');disp(' ');
    disp('Computing base flow and adapting mesh');
    baseflow = FreeFem_Init('mesh_Init_Sphere.edp') 
    
    Re_start = [10 , 100 , 250]; % values of Re for progressive increasing up to end
    for Rei = Re_start
        baseflow=FreeFem_BaseFlow(baseflow,Rei) 
        baseflow=FreeFem_Adapt(baseflow)
    end
    Re = 250;
    
 % optional : adapting mesh on eigenmode structure as well  
 %shift = -0.071+0.707i;% for unsteady mode
 shift = 0.0867;%for steady mode
 [ev,eigenmode] = FreeFem_Stability(baseflow,Re,1,shift,1)
 [baseflow,eigenmode]=FreeFem_Adapt(baseflow,eigenmode);  
 
 baseflow.mesh.xlim=[-1,3]; %x-range for plots
 baseflow.mesh.ylim=[0,3];  %y-range for plots
 plotFF(baseflow,'mesh');
 plotFF(baseflow,'u0');  


  disp(' ');disp('### '); disp('### CHAPTER 1 : ');disp('### ');disp(' ');
 disp('Computing stability branches in the range Re = [200-300] for the first two branches');
    % stability calculations with loop over Re
    Re_RangeS = [200:10:300];
    Re_RangeI = [250:10:300];
if(1==0)
    
    % Unsteady mode branch
        EVI = FreeFem_Stability_LoopRe(baseflow,Re_RangeI,1,-.076+0.707i,1);
    % Steady mode branch
        EVS = FreeFem_Stability_LoopRe(baseflow,Re_RangeS,1,-0.038,1);
  
    figure;
    subplot(2,1,1);
    plot(Re_RangeS,real(EVS),'-*b',Re_RangeI,real(EVI),'-*r')
    title('growth rate Re(sigma) vs. Reynolds ; unstready mode (red) and steady mode (blue)')
    subplot(2,1,2);
    plot(Re_RangeS,imag(EVS),'-*b',Re_RangeI,imag(EVI),'-*r')
    title('oscillation rate Im(sigma) vs. Reynolds')
end

  

      disp(' ');disp('### '); disp('### CHAPTER 2 : ');disp('### ');disp(' ');
    
    disp(['Direct, Adjoint and structural sensitivity ; unsteady mode for Re=250']);
   
    Rec = 212.58;
    m = 1;
     shift = -0.071+0.707i;
    baseflow = FreeFem_BaseFlow(baseflow,250);
    baseflow.mesh.xlim = [-1,3];
    baseflow.mesh.ylim = [0 3];
    [evD,eigenmodeD]=FreeFem_Stability(baseflow,Re,m,shift,1);
    disp([' eigenvalue = ',num2str(eigenmode.sigma)]);
    eigenmodeD.plottitle = 'Direct mode';
    plotFF(eigenmodeD,'ux1',1);
   
    [evA,eigenmodeA]=FreeFem_Stability(baseflow,Re,m,shift,1,'A');
    eigenmodeA.plottitle = 'Adjoint mode';
    plotFF(eigenmodeA,'ux1',1);
    
    wavemaker.mesh = eigenmode.mesh;
    wavemaker.plottitle = 'structural sensitivity';
    wavemaker.sensitivity=abs(eigenmode.ux1).*abs(eigenmodeA.ux1)+abs(eigenmode.ur1).*abs(eigenmodeA.ur1)+abs(eigenmode.ut1).*abs(eigenmodeA.ut1);
    plotFF(wavemaker,'sensitivity');
    
   
      
    
    disp(' ');disp('### '); disp('### CHAPTER 3 : ');disp('### ');disp(' ');
 
        disp('Computing coefficients of the weakly nonlinear amplitude equation');
        disp('NB : at the moment this will work only for steady, m=1 bifurcation'); 
        Rec = 212.58;
        m = 1;
         
        disp(['Rec = ', num2str(Rec)]);
        baseflow=FreeFem_BaseFlow(baseflow,Rec);
        [evD,eigenmodeD]=FreeFem_Stability(baseflow,Rec,m,0,1);
        eigenmodeD;
        [evA,eigenmodeA]=FreeFem_Stability(baseflow,Rec,m,0,1,'A');
        eigenmodeA;
        wnl_coeffs = FreeFem_WNL(baseflow)
            
    


