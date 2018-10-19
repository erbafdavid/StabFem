% Matlab interface for GlobalFem
%
%   (set of programs in Freefem to perform global stability calculations in hydrodynamic stability)
%  
%  THIS SCRIPT DEMONSTRATES STABFEM FOR Spring-Mounted Cylinder
%
%  Revised on oct. 18, 2018 in ONERA with DIOGO
%
%

run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=15;

if(exist('bf')==1)
    disp('Mesh / base flow previously computed');
else
    bf = SmartMesh_Cylinder('S');
end

%% Loop over Re for fixed case

disp(' ');
disp('COMPUTING STABILITY BRANCH (fixed cylinder) ')
disp(' ');



figure(10);hold on;

Re_range = [60: -2.5 : 40];guessS = .04+.74i;
bf.mesh.problemtype = '2D';
[EVFixed,Rec,omegac] = SF_Stability_LoopRe(bf,Re_range,guessS,'plot','r');


%% Loop over Re for spring-mounted case

    
disp(' ');
disp('COMPUTING STABILITY BRANCH FOR VIV CASE (M=10,K=1) ')
disp(' ');
% starting point
bf.mesh.problemtype = '2DMobile';
bf=SF_BaseFlow(bf,'Re',42.5);
[ev,em] = SF_Stability(bf,'shift',-0.0262 + 0.7076i,'nev',20,'type','D','STIFFNESS',1,'MASS',10,'DAMPING',0,'plotspectrum','yes');
guessS = ev(1);
Re_tab = [40 : 2.5 : 60];
figure(10);hold on;
[EV_10_1,Rec,omegac] = SF_Stability_LoopRe(bf,Re_tab,guessS,'STIFFNESS',1,'MASS',10,'DAMPING',0,'plot','b');

%figure(10); hold on;
%plot(Re_tab,real(EV_10_1),'r--');
%title('amplification rate');

%figure(11);hold on;
%plot(Re_tab,imag(EV_10_1),'b--');

