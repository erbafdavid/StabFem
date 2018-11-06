
run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=1;

%%
dsurD = 0.5;
%% Generation of the base flow

    bf = SmartMesh_L2(dsurD);
    bf.mesh.xlim = [-2 6];
    bf.mesh.ylim = [-1 1];
 
% plot the base flow
figure;plotFF(bf,'ux','contour','on','clevels',[0,0]);  %
pause(0.1);


%% Spectrum explorator 
[ev,em] = SF_Stability(bf,'m',1,'shift',.5+0.4i,'nev',20,'type','D','plotspectrum','yes');   
pause(0.1);
 figure;
    subplot(2,1,1);plotFF(em(1),'ux1','symmetry','XA','colormap','redblue','boundary','on','bdlabels',[1 21 22 23],'bdcolors','brrr','colorrange','cropcentered','cbtitle','u_x''');hold on;title('Blunt body : steady mode')
    subplot(2,1,2);plotFF(em(2),'ux1','symmetry','XA','colormap','redblue','boundary','on','bdlabels',[1 21 22 23],'bdcolors','brrr','colorrange','cropcentered','cbtitle','u_x''');hold on;title('Blunt body : unsteady mode')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.75;set(gcf,'Position',pos);
saveas(gcf,'FIGURES/BluntBody_L2_D2_Modes','png');
pause(0.1);
 
%% COMPUTING THE UNSTEADY BRANCH (going backwards)
Re_RangeI = [500:-20:300];
guessI =  0.1654 + 0.8358i;
figure(10);
[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','r');

ReI_05=ResI
       
%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [500:-50:300 280 :-20:140];
guessS = 0.3;
[EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','r');

ReS_05=ResS


%%
dsurD = 0.25;
%% Generation of the base flow

    bf = SmartMesh_L2(dsurD);

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
Re_RangeI = [500:-20:300];
guessI =  0.0413 + 0.6817i;
figure(10);
[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','b');

ReI_025=ResI
       
%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [500:-50:300 280 :-20:200];
guessS = 0.1558;
[EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','b');

ReS_025=ResS

%%
dsurD = 0.65;
%% Generation of the base flow

    bf = SmartMesh_L2(dsurD);

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
Re_RangeI = [500:-25:200];
guessI =  0.2891 + 1.1064i;
figure(10);
[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','g');

guessI = 0.058946+1.7143i;
[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,[200:-10:160],guessI,'plot','g');

ReI_065=ResI

%Re_RangeI = [500:-20:300];
%guessI =  0.1852 + 1.9135i;
%figure(10);
%[EVI2,ResI2,omegasI2] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','g');
%ReI2_065=ResI2



%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [500:-50:200 180 :-20:120];
guessS = 0.5416;
[EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','g');

ReS_065=ResS

%%
%Re_RangeS = [500:-50:300 280 :-20:140];
%guessS = 0.1244 + 0.0000i;
%[EVS2,ResS2,omegasS2] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','g');
%ReS2_065=ResS2


%% Localizing the instability threshold




%% Localizing the instability threshold

% [bf,ev] = SF_FindThreshold(bf,ev) % available soon...


%%
dsurD = 0.8;
%% Generation of the base flow

   Rbody = 0.5; Lel = 1; Lcyl = 1; Rpipe = 0.5/dsurD; xmin = -10; xmax = 60;Lbody=Lcyl+Lel;
bctype = 1;

    bf = SF_Init('meshInit_BluntBodyInTube.edp',[Rbody Lel Lcyl Rpipe xmin xmax bctype]); 
    Re_start = [10 , 30, 60, 100 , 200]; % values of Re for progressive increasing up to end
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei); 
        bf=SF_Adapt(bf,'Hmax',1);
    end
 
  % adapting mesh on eigenmode structure as well      
 shift =  0.3078 + 3.4918i;
 ev = SF_Stability(bf,'m',1,'shift',shift,'nev',10);
 shift=ev(1);
 [ev,eigenmode] = SF_Stability(bf,'m',1,'shift',shift,'nev',1,'type','A');
 [bf,eigenmode] = SF_Adapt(bf,eigenmode); 
 [ev,eigenmode] = SF_Stability(bf,'m',1,'shift',shift,'nev',1,'type','A');
 [bf,eigenmode] = SF_Adapt(bf,eigenmode); 

% plot the base flow
figure;plotFF(bf,'ux','contour','on','clevels',[0,0]);  %
pause(0.1);

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
verbosity=2;
Re_RangeI = [200:-10:150];
guessI =  0.3078 + 3.4918i;
figure(10);
[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','c');
ReI_08=ResI

%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [200 :-10:100];
guessS = 0.98
[EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','c');

ReS_08=ResS
