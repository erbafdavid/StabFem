clear all
format shortG


run('/Users/theomouyen/Documents/GitHub/StabFem/SOURCES_MATLAB/SF_Start.m');
close all;

%ffdatadir = './WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational

%%% PARAMETRES

Rbody = 0.5; Lel = 1; Lcyl = 5;Rpipe = 10; xmin = -10; xmax = 60;


Lbody=Lcyl+Lel;
bctype = 1;

nit = 5;    % nombre d'iterations du adaptmesh
Hmax = 1;   %taille max des mailles
n=2;        %densité du méillage: voir meshInit_BluntbodyInTube.edp
ReInit=800; %Reynolds initial
Guess=0.5i;    %où chercher la perturbation

%%% FIN PARAMETERS

    disp('computing base flow and adapting mesh');
    
    Re_start = [10 , 30, 60, 100, 200]; 
    bf = SF_Init('meshInit_BluntBodyInTube.edp',[Rbody Lel Lcyl Rpipe xmin xmax bctype]); 
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei); 
        bf=SF_Adapt(bf,'Hmax',Hmax);
        disp(['delta min : ',num2str(bf.mesh.deltamin)]);
        disp(['delta max : ',num2str(bf.mesh.deltamax)]);
    end
   
   
    
bf=SF_BaseFlow(bf,'Re',ReInit);
bf=SF_Adapt(bf,'Hmax',Hmax);
disp(['delta min : ',num2str(bf.mesh.deltamin)]);
disp(['delta max : ',num2str(bf.mesh.deltamax)]);
figure
plotFF(bf,'mesh');


[ev,em] = SF_Stability(bf,'m',1,'shift',Guess,'nev',1); % type 'S' ou 'D' sans effet   

ev0=0;
ev0=ev;

ev_tab = ev0;
Npt_tab = bf.mesh.np;

ev0

for itab = 1:nit

    bf = SF_Adapt(bf,em,'Hmax',Hmax);
    [ev1,em] = SF_Stability(bf,'m',1,'shift','prev','nev',1);
    ev1
    ev_tab = [ev_tab ev1];
    Npt_tab = [Npt_tab bf.mesh.np];

end

Nit_tab  = [0 : nit];


figure;
plot(Nit_tab,real(ev_tab),'kx');
title(['Re(sigma) for N = 2 and Hmax = ',num2str(Hmax),' and xmax = ',num2str(xmax)] )

figure;
plot(Nit_tab,imag(ev_tab),'bo');

figure;
plot(Nit_tab,abs(ev_tab-ev_tab(end))/abs(ev_tab(end)),'r*')

figure;
plot(Nit_tab,Npt_tab,'gs');

X= [n*ones(length(Nit_tab),1) Hmax*ones(length(Nit_tab),1) xmax*ones(length(Nit_tab),1) Nit_tab' Npt_tab' Rpipe*ones(length(Nit_tab),1) Lbody*ones(length(Nit_tab),1) ReInit*ones(length(Nit_tab),1) real(ev_tab)' imag(ev_tab)'];
save(['dataConv_N' num2str(n) '_H' num2str(Hmax*100) '_Xm' num2str(xmax) '_Rp' num2str(Rpipe*100) '_LD' num2str(Lbody) '_Re' num2str(ReInit) '.txt'],'X','-ascii');
 

%  
% % astuce pour multiplier par 2 la densite du maillage
% % bf = SF_Split(bf);
% 


% 
% ev1 %1
% 
% bf = SF_Adapt(bf,em);
% [ev2,em] = SF_Stability(bf,'m',1,'shift',ev1,'nev',1,'type','S');
% 
% 
% ev2 %2
% 
% bf = SF_Adapt(bf,em);
% [ev3,em] = SF_Stability(bf,'m',1,'shift',ev2,'nev',1,'type','S');
% 
% 
% ev3 %3
% 
% bf = SF_Adapt(bf,em);
% [ev4,em] = SF_Stability(bf,'m',1,'shift',ev3,'nev',1,'type','S');
% 
% 
% ev4 %4
% 
% bf = SF_Adapt(bf,em);
% [ev5,em] = SF_Stability(bf,'m',1,'shift',ev4,'nev',1,'type','S');
% 
% 
% ev5 %5
% 
% bf = SF_Adapt(bf,em);
% [ev6,em] = SF_Stability(bf,'m',1,'shift',ev5,'nev',1,'type','S');
% 
% 
% ev6 %6
% 
% bf = SF_Adapt(bf,em);
% [ev7,em] = SF_Stability(bf,'m',1,'shift',ev6,'nev',1,'type','S');
% 
% 
% ev7 %7
% 
% bf = SF_Adapt(bf,em);
% [ev8,em] = SF_Stability(bf,'m',1,'shift',ev7,'nev',1,'type','S');
% 
% 
% ev8 %8
% 
% bf = SF_Adapt(bf,em);
% [ev9,em] = SF_Stability(bf,'m',1,'shift',ev8,'nev',1,'type','S');
% 
% 
% ev9 %9
% 
% bf = SF_Adapt(bf,em);
% [ev10,em] = SF_Stability(bf,'m',1,'shift',ev9,'nev',1,'type','S');
% 
% 
% ev10 %10
% 
% keepNew_N3_Hmax50= [10*ones(11,1) 6*ones(11,1) 3*ones(11,1) 0.5*ones(11,1) 800*ones(11,1) [0 1 2 3 4 5 6 7 8 9 10]' [real(ev0) real(ev1) real(ev2) real(ev3) real(ev4) real(ev5) real(ev6) real(ev7) real(ev8) real(ev9) real(ev10)]' [imag(ev0) imag(ev1) imag(ev2) imag(ev3) imag(ev4) imag(ev5) imag(ev6) imag(ev7) imag(ev8) imag(ev9) imag(ev10)]'];
% 
%  
% save('dataNew_N3_Hmax50.txt','keepNew_N3_Hmax50','-ascii');


