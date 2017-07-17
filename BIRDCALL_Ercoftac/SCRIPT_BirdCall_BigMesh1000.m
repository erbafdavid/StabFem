global ff ffdir ffdatadir sfdir 
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw -v 0'; %% Freefem command with full path 
sfdir = '../SOURCES_MATLAB'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts
ffdatadir = './DATA_FREEFEM_BIRDCALL_ERCOFTAC';
addpath(sfdir);

Re = 1000; % Reference value for the robust mesh generation

if(exist([ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'])==2)
    disp(['base flow and adapted mesh for Re = ' num2str(Re) ' already computed']);
    if(exist('baseflow')==0) % may happen for instance after clear all or restart
        bf.mesh = importFFmesh('mesh.msh');
    	bf = FreeFem_BaseFlow(bf,1000); 
    end
    
else
    disp('computing base flow and adapting mesh')

bf = FreeFem_Init('Mesh_BirdCall.edp');
ReTab = [10, 100, 200, 350, 550, 750, 1000]%, 1250, 1500];
for Re = ReTab
    bf = FreeFem_BaseFlow(bf,Re);
    if(Re>10) 
        bf = FreeFem_Adapt(bf);
    end
end

[eV,eM] = FreeFem_Stability(bf,Re,0,0.6301+5.7635i,10);
[ev,em] = FreeFem_Stability(bf,Re,0,eV(1),1);


[bf]=FreeFem_Adapt(bf,em);  

bf.mesh.xlim=[-2,5];
bf.mesh.ylim=[0 4];
plotFF(bf,'mesh');
plotFF(bf,'u0');  

end
 
 
%%% NEXT IF TO COMPUTE BRANCHES

if(1==0)

% detected eigenvalues : à(for Re= 1000), in accordance with Benjamin :
% 0.2567 + 5.7401i (St = 0.

% first one  
% Benjamin :    0.4837 + 3.5115i (St = 0.55) 
%   after meshadapt on this mode only
guess1 = 0.480839 + 3.51013i;

%second one : 
% Benjamin : 0.637183+5.7603i (St  = 0.91678 )
% my case : 0.6301 +i 5.7635
guess2 =  0.6301 +5.7635i;

% third one :
guess3 = 0.2684 + 7.9422i;

% number 4 : 
% rien trouve autour de 10



Re_Range = [1000:-40:300];

    
    if(exist('EV1')==0)
        EV1 = FreeFem_Stability_LoopRe(bf,Re_Range,0,guess1,1);
    end
    if(exist('EV2')==0)
        EV2 = FreeFem_Stability_LoopRe(bf,Re_Range,0,guess2,1);
    end
    if(exist('EV3')==0)
        EV3 = FreeFem_Stability_LoopRe(bf,Re_Range,0,guess3,1);
    end
    
    figure;
    subplot(2,1,1);
    plot(Re_Range,real(EV1),'-*b',Re_Range,real(EV1),'-*r',Re_Range,real(EV1),'-*g')
    title('growth rate Re(sigma) vs. Reynolds ; unstready mode (red) and steady mode (blue)')
    subplot(2,1,2);
    plot(Re_Range,imag(EV1)/(2*pi),'-*b',Re_Range,imag(EV2)/(2*pi),'-*b',Re_Range,imag(EV3)/(2*pi),'-*g')%,Re_Range,imag(EVI),'-*r')
    title('Strouhal vs. Reynolds');

end
    !