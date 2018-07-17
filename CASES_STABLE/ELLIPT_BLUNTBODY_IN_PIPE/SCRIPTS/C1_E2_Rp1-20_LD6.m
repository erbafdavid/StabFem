clear all
format shortG


run('/Users/theomouyen/Documents/GitHub/StabFem/SOURCES_MATLAB/SF_Start.m');
close all;

%ffdatadir = './WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational

%%% PARAMETRES

Rbody = 0.5; Lel = 1; Lcyl = 5;Rpipe = 1.20; xmin = -10; xmax = 120;


Lbody=Lcyl+Lel;
bctype = 1;

Hmax = 1; %taille max des mailles
n=2; %densité du méillage: voir meshInit_BluntbodyInTube.edp

%%% FIN PARAMETERS

    disp('computing base flow and adapting mesh');
    
    Re_start = [10 , 30, 60, 100, 200,300,400,500,600,700,800,900,1000,1050]; 
    bf = SF_Init('meshInit_BluntBodyInTube.edp',[Rbody Lel Lcyl Rpipe xmin xmax bctype]); 
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei);
        bf=SF_Adapt(bf,'Hmax',Hmax);
        disp(['delta min : ',num2str(bf.mesh.deltamin)]);
        disp(['delta max : ',num2str(bf.mesh.deltamax)]);
    end
   
% compute a spectrum  
         
%  [ev1,eigenmode1] = SF_Stability(bf,'m',1,'shift',0,'nev',10,'plotspectrum','yes');   
%  [ev2,eigenmode2] = SF_Stability(bf,'m',1,'shift',0.4i,'nev',10,'plotspectrum','yes');   
%  [ev3,eigenmode3] = SF_Stability(bf,'m',1,'shift',0.8i,'nev',10,'plotspectrum','yes');   
%  [ev4,eigenmode4] = SF_Stability(bf,'m',1,'shift',1.2i,'nev',10,'plotspectrum','yes');   
%  [ev5,eigenmode5] = SF_Stability(bf,'m',1,'shift',1.6i,'nev',10,'plotspectrum','yes');   
%  [ev6,eigenmode6] = SF_Stability(bf,'m',1,'shift',2i,'nev',10,'plotspectrum','yes');   
%  [ev7,eigenmode7] = SF_Stability(bf,'m',1,'shift',2.4i,'nev',10,'plotspectrum','yes');   
% 
%  pause(0.1);
%
% evtot=[ev1 ev2 ev3 ev4 ev5 ev6 ev7]

%% Guess des nombres de Reynolds

ReSi=250;
guessReS=0i;

ReIi=500;
guessReI=0.5i;

Readjust;           %Pour la première paire de modes

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
ReIi;
ReIf=ReIi-50;
    Re_RangeI = [ReIi:-5:ReIf];EVI = [];
        guessI = ev01;
        bf=SF_BaseFlow(bf,'Re',ReIi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeI
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI = [EVI ev];
        end  
 
%% COMPUTING THE STEADY BRANCH (going backwards)
ReSi;
ReSf=ReSi-50;
    Re_RangeS = [ReSi:-5:ReSf];EVS = [];
        guessS = ev00;
        bf=SF_BaseFlow(bf,'Re',ReSi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessS,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeS
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVS = [EVS ev];
        end  
     
 %% Résultat 1:
 
[ReCS,ReCI,ImCI]=Recritique(guessReS,guessReI,EVS,EVI,Re_RangeS,Re_RangeI,bf,Hmax); 

M1= [[1 2]' [bctype bctype]' [Rpipe Rpipe]' [Lbody Lbody]' [ReCS ReCI]' [0  ImCI]'];
save(['dataC' num2str(bctype) '_E2_Rp' num2str(Rpipe*100) 'LD' num2str(Lbody*100) '(1).txt'],'M1','-ascii');

        
%% Deuxième couple
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
ReIi=525;
guessReI=1i;

ReSi=750;
guessReS=0i;


Readjust2;        % Pour la deuxième paire de modes
        

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
ReIi;
ReIf=ReIi-50;
    Re_RangeI = [ReIi:-5:ReIf];EVI = [];
        guessI = ev01;
        bf=SF_BaseFlow(bf,'Re',ReIi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeI
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI = [EVI ev];
        end  
 
%% COMPUTING THE STEADY BRANCH (going backwards)
ReSi;
ReSf=ReSi-50;
    Re_RangeS = [ReSi:-5:ReSf];EVS = [];
        guessS = ev00;
        bf=SF_BaseFlow(bf,'Re',ReSi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessS,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeS
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVS = [EVS ev];
        end  
     
 %% Résultat 2: 
 

[ReCS,ReCI,ImCI]=Recritique(guessReS,guessReI,EVS,EVI,Re_RangeS,Re_RangeI,bf,Hmax);

M2= [[3 4]' [bctype bctype]' [Rpipe Rpipe]' [Lbody Lbody]' [ReCS ReCI]' [0  ImCI]'];
save(['dataC' num2str(bctype) '_E2_Rp' num2str(Rpipe*100) 'LD' num2str(Lbody*100) '(2).txt'],'M2','-ascii');





%% PAIRES DE MODES INSTATIONNAIRES (Rp<3 et Re>900)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



ReI1i=1100;
guessReI1=1.2i;

ReI2i=1150;
guessReI2=0.4i;

Readjust3;        % Pour la deuxième paire de modes
%% COMPUTING THE UNSTEADY1 BRANCH (going backwards)
ReI1i;
ReI1f=ReI1i-50;
    Re_RangeI1 = [ReI1i:-5:ReI1f];EVI1 = [];
        guessI1 = ev01;
        bf=SF_BaseFlow(bf,'Re',ReI1i);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI1,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeI1
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI1 = [EVI1 ev];
        end  
 
 
%% COMPUTING THE UNSTEADY2 BRANCH (going backwards)
ReI2i;
ReI2f=ReI2i-50;
    Re_RangeI2 = [ReI2i:-5:ReI2f];EVI2 = [];
        guessI2 = ev00;
        bf=SF_BaseFlow(bf,'Re',ReI2i);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI2,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeI2
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI2 = [EVI2 ev];
        end  
     
%%

[ReCI1,ReCI2,ImCI1,IMCI2]=Recritique2(guessReI1,guessReI2,EVI1,EVI2,Re_RangeI1,Re_RangeI2,bf,Hmax);

M3= [[5 6]' [bctype bctype]' [Rpipe Rpipe]' [Lbody Lbody]' [ReCI1 ReCI2]' [ImCI1  ImCI2]'];
save(['dataC' num2str(bctype) '_E2_Rp' num2str(Rpipe*100) 'LD' num2str(Lbody*100) '(3).txt'],'M3','-ascii');



