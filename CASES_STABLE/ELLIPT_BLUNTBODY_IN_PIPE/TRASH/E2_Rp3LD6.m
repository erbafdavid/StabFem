clear all

run('/Users/theomouyen/Documents/GitHub/StabFem/SOURCES_MATLAB/SF_Start.m');
close all;


%ffdatadir = './WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational

Rbody = 0.5; Lel = 1; Lcyl = 5;Rpipe = 3; xmin = -10; xmax = 30;
Lbody=Lcyl+Lel;
bctype = 1;

    disp('computing base flow and adapting mesh');
    bf = SF_Init('meshInit_BluntBodyInTube.edp',[Rbody Lel Lcyl Rpipe xmin xmax bctype]); 
    Re_start = [10 , 30, 60, 100 , 200]; % values of Re for progressive increasing up to end
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei); 
        bf=SF_Adapt(bf,'Hmax',0.5);
    end
   
% compute a spectrum  

 [ev1,eigenmode1] = SF_Stability(bf,'m',1,'shift',0,'nev',10,'type','D','plotspectrum','yes');   

 [ev2,eigenmode2] = SF_Stability(bf,'m',1,'shift',1i,'nev',10,'type','D','plotspectrum','yes');   

 [ev3,eigenmode3] = SF_Stability(bf,'m',1,'shift',0.2+0.5i,'nev',10,'type','D','plotspectrum','yes');   


 [ev4,eigenmode4] = SF_Stability(bf,'m',1,'shift',0.5,'nev',10,'type','D','plotspectrum','yes');   

 [ev5,eigenmode5] = SF_Stability(bf,'m',1,'shift',0.5+0.5i,'nev',10,'type','D','plotspectrum','yes');   

 [ev6,eigenmode6] = SF_Stability(bf,'m',1,'shift',0.5+2i,'nev',10,'type','D','plotspectrum','yes');   

 [ev7,eigenmode7] = SF_Stability(bf,'m',1,'shift',-0.25+2i,'nev',10,'type','D','plotspectrum','yes');   
pause(0.1);

evtot=[ev1 ev2 ev3 ev4 ev5 ev6 ev7]

% range for figures
bf.mesh.xlim=[-2*Rbody,Lbody+5*Rbody]; %x-range for plots
bf.mesh.ylim=[0,Rpipe];
plotFF(bf,'mesh'); % to plot the mesh

bf.mesh.xlim=[-2*Rbody,Lbody+5*Rbody]; %x-range for plots
bf.mesh.ylim=[0,Rpipe];
plotFF(bf,'ux');  % to plot the bf
pause(0.1);

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
ReIi=750;
ReIf=700;
    Re_RangeI = [ReIi:-5:ReIf];EVI = [];
        guessI = 0.0041 + 0.4889i;
        bf=SF_BaseFlow(bf,'Re',ReIi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI,'nev',1,'type','D');
        bf=SF_Adapt(em,'Hmax',0.5); %A confirmer
        for Re = Re_RangeI
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI = [EVI ev];
        end  
 
%% COMPUTING THE STEADY BRANCH (going backwards)
ReSi=400;
ReSf=350;
    Re_RangeS = [ReSi:-5:ReSf];EVS = [];
        guessS = 0.0121 + 0.0000i;
        bf=SF_BaseFlow(bf,'Re',ReSi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessS,'nev',1,'type','D');
        bf=SF_Adapt(em,'Hmax',0.5);%A confirmer
        for Re = Re_RangeS
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVS = [EVS ev];
        end  
     
        
 %% Résultat: Reynolds critiques%
[ReCS,ReCI,ImCI]=Recritique(EVS,EVI,Re_RangeS,Re_RangeI,bf); 

keepE2_Rp3LD6= [[1 2]' [Rpipe Rpipe]' [Lbody Lbody]' [ReCS ReCI]' [0  ImCI]'];

save(['dataE2_Rp' num2str(Rpipe) 'LD' num2str(Lbody) '.txt'],['keepE2_Rp' num2str(Rpipe) 'LD' num2str(Lcyl+Lel)],'-ascii');
 