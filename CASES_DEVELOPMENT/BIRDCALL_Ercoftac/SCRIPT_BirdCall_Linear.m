
%% CHAPTER O : initialisations

run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
ffdatadir = './DATA_SF_BIRDCALL_ERCOFTAC/';
close all;

%% Chapter 1 : generation of a mesh

if(exist('./DATA_SF_BIRDCALL_ERCOFTAC/MESHES/BaseFlow_adapt_Re1000.txt')==2)
    disp('BaseFlow already computed : recovering it')
    ffmesh = importFFmesh('./DATA_SF_BIRDCALL_ERCOFTAC/MESHES/mesh_adapt_Re1000.msh')
    bf = importFFdata(ffmesh,'./DATA_SF_BIRDCALL_ERCOFTAC/MESHES/BaseFlow_adapt_Re1000.ff2m')
else
    bf = SmartMesh_BirdCall;
end

 
%% Chapter 1b : figures

figure();plotFF(bf,'mesh','xlim',[-1 5],'ylim',[0 4]);
figure();plotFF(bf,'ux','xlim',[-1 5],'ylim',[0 4]); 

%% 1C : spectrum exploration
%ev = SF_Stability(bf,'m',0,'shift',2 + 5i,'nev',20,'type','D');
%figure();plot(real(ev),imag(ev),'xr');title('spectrum for Re=1000');hold on;
%ev = SF_Stability(bf,'m',0,'shift',2 + 9i,'nev',20,'type','D');
%plot(real(ev),imag(ev),'xr');title('spectrum for Re=1000');hold on;

%% CHAPTER 2 : stability branches

if(exist('data.mat')==0)

% first one  
% Benjamin :    0.4837 + 3.5115i (St = 0.55) 
%   Ercoftac:
%guess1 = 0.480839 + 3.51013i;
% now :
guess1 = 0.4512 + 3.5440i;


%second one : 
% Benjamin : 0.637183+5.7603i (St  = 0.91678 )
% Ercoftac : 0.6301 +i 5.7635
% now :
guess2 =  0.9045 + 5.7059i;

% third one :
% ercoftac :
%guess3 = 0.2684 + 7.9422i;
guess3 = 0.7567 + 7.9162i;


% number 4 : 
% rien trouve autour de 10
guess4 = 0.178 + 10.256i;



Re_Range1=[1000:-50:150];Re_Range2=Re_Range1;Re_Range3=Re_Range1;Re_Range4=Re_Range1;
Re_Range4=[1000:-50:600];
EV1 = []; EV2 = []; EV3 = []; EV4 = [];DeltaP = [];

bf = SF_BaseFlow(bf,'Re',1000);
ev = SF_Stability(bf,'m',0,'shift',guess1,'nev',1);
for Re = Re_Range1    
    bf = SF_BaseFlow(bf,'Re',Re);
    [ev,em] = SF_Stability(bf,'m',0,'shift','cont','nev',1);
    if(em.iter~=-1) 
        EV1 = [EV1 ev];
        DeltaP = [DeltaP bf.Pup];
    else
        break;
    end;
end
Re_Range1 = Re_Range1(1:length(EV1));
DeltaP = DeltaP(1:length(EV1));


bf = SF_BaseFlow(bf,'Re',1000);
ev = SF_Stability(bf,'m',0,'shift',guess2,'nev',1);
for Re = Re_Range2    
    bf = SF_BaseFlow(bf,'Re',Re);
    [ev,em] = SF_Stability(bf,'m',0,'shift','cont','nev',1);
    if(em.iter~=-1) EV2 = [EV2 ev];
        else break;
    end;
end
Re_Range2 = Re_Range2(1:length(EV2));

bf = SF_BaseFlow(bf,'Re',1000);
ev = SF_Stability(bf,'m',0,'shift',guess3,'nev',1);
for Re = Re_Range3    
    bf = SF_BaseFlow(bf,'Re',Re);
    ev = SF_Stability(bf,'m',0,'shift','cont','nev',1);
    if(em.iter~=-1) EV3 = [EV3 ev];
        else break; 
    end;
end
Re_Range3 = Re_Range3(1:length(EV3));

bf = SF_BaseFlow(bf,'Re',1000);
ev = SF_Stability(bf,'m',0,'shift',guess4,'nev',1);
for Re = Re_Range4    
    bf = SF_BaseFlow(bf,'Re',Re);
    ev = SF_Stability(bf,'m',0,'shift','cont','nev',1);
    if(em.iter~=-1) EV4 = [EV4 ev];
        else break; 
    end;
end
Re_Range4 = Re_Range4(1:length(EV4));
% save
save('data.mat','Re_Range1','Re_Range2','Re_Range3','Re_Range4','EV1','EV2','EV3','EV4');

else

load('data.mat');
end

%% chapter 2b : figures

    figure(10);
    subplot(2,1,1);
    plot(Re_Range1,real(EV1),'-*b',Re_Range2,real(EV2),'-*r',Re_Range3,real(EV3),'-*g',Re_Range4,real(EV4),'-*c');ylim([0 1]);
    title('growth rate Re(sigma) vs. Reynolds');
    subplot(2,1,2);
    plot(Re_Range1,imag(EV1)/(2*pi),'-*b',Re_Range2,imag(EV2)/(2*pi),'-*r',Re_Range3,imag(EV3)/(2*pi),'-*g',Re_Range4,imag(EV4)/2/pi,'-*c');
    title('Strouhal vs. Reynolds');

    figure(11);
    plot(Re_Range1,DeltaP,'-b');
    title('Pressure drop coefficient across the whistle');
    
    figure(12);
    plot(Re_Range1,real(EV1),'-*b',Re_Range2,real(EV2),'-*r',Re_Range3,real(EV3),'-*g',Re_Range4,real(EV4),'-*c');ylim([0 1]);
    title('growth rate Re(sigma) vs. Reynolds');

