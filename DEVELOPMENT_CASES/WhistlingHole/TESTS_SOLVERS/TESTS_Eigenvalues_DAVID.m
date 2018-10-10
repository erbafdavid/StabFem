

% This script computes eigenvalues for a whistling jet through a hole with beta = 1.

% NOT WORKING YET, BUT THIS IS TO DEMONSTRATE HOW IT (doesn't) WORK...



run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;


%% chi = 1

chi = 1;
Re = 1500;
if(exist('bf'))
    bf = SF_BaseFlow(bf,'Re',Re);
else
    bf = SmartMesh_Hole(chi);
end

% FOR Re = 1500, according to impedance predictions, there should be a 
% nearly-neutral eigenvalue close to omega = \pm 2.1i
%
% If i'm right the complex-mapping method should allow to calculate the
% eigenvalue with negative imaginary part (lambda = sigma - i omega with omega >0) 

% First test : USING general solver Stab_Axi_COMPLEX.edp (adapted from other sources of the StabFem project) 
% nev = 20 => Slepc solver

%% 
evG = SF_Stability(bf,'shift',-2i+.5,'m',0,'nev',20)
evGplus = SF_Stability(bf,'shift',+2i+.5,'m',0,'nev',20,'plotspectrum','yes')
evGzero = SF_Stability(bf,'shift',.5,'m',0,'nev',20)

%%% We get the following eigenvalue : 0.0395 + 2.5368i

%evG1 = SF_Stability(bf,'shift',-2.1i,'m',0,'nev',1) %-> not converging 
%evG1 = SF_Stability(bf,'shift',0.04 + 2.54i,'m',0,'nev',1) % -> not converging 

%% SECOND test : USING solver  Stab_Axi_COMPLEX_m0.edp adapted from Raffaele's sources
ev = SF_Stability(bf,'shift',-2i+.5,'m',0,'nev',20,'solver','StabAxi_COMPLEX_m0.edp','plotspectrum','yes')
evplus = SF_Stability(bf,'shift',+2i+.5,'m',0,'nev',20,'solver','StabAxi_COMPLEX_m0.edp')
evzero = SF_Stability(bf,'shift',.5,'m',0,'nev',20,'solver','StabAxi_COMPLEX_m0.edp')

%%% We get the following eigenvalue :
%0.0091 - 2.0686i

ev1 = SF_Stability(bf,'shift',-2.1i,'m',0,'nev',1,'solver','StabAxi_COMPLEX_m0_nev1.edp') %-> not converging


%% FIGURE
figure(6);hold off;
%plot(evG,evG1,ev,ev1)
plot(real(evG), -imag(evG),'b+')
hold on;
plot(real(evGplus), -imag(evGplus),'bx');
plot(real(evGzero), -imag(evGplus),'bs');
%plot(real(evG1),imag(evG1),'bo')


plot(real(ev),imag(ev),'r+') ; hold on;
plot(real(evplus), imag(evGplus),'rx')
plot(real(evzero), imag(evGzero),'rs')
hold on;
%plot(real(ev1),imag(ev1),'ro')

axis equal;
legend( 'Stab_Axi_Complex.edp, shift = -2i+.5','Stab_Axi_Complex.edp, shift = +2i+.5','Stab_Axi_Complex.edp, shift = .5',...%'Stab_Axi_Complex.edp, S/I',...
        'Stab_Axi_Complex_m0.edp, shift = -2i+.5','Stab_Axi_Complex_m0.edp, shift = +2i+.5','Stab_Axi_Complex_m0.edp, shift = .5);%'Stab_Axi_Complex_m0.edp, S/I');

%% Loop over Re 

Re_Range = [1500 : 100 :2000];

EV1 = SF_Stability_LoopRe(bf,Re_Range,0+2.06i,'m',0,'nev',10);
    