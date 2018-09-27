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
evG = SF_Stability(bf,'shift',-2.1i,'m',0,'nev',20)
% nev = 1 => shift-invert solver
evG1 = SF_Stability(bf,'shift',-2.1i,'m',0,'nev',20)

% SECOND test : USING solver  Stab_Axi_COMPLEX_m0.edp adapted from Raffaele's sources
% note that this solver is switched on by the "trick" m = 0+1i...
% nev = 20 => Slepc solver
ev = SF_Stability(bf,'shift',-2.1i,'m',0+1i,'nev',20)
% nev = 1 => shift-invert solver
ev1 = SF_Stability(bf,'shift',-2.1i,'m',0+1i,'nev',20)

scatter(real(evG), imag(evG),'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
hold on;
scatter(real(evG1),imag(evG1),'s','red',...
              'LineWidth',1.5)

scatter(real(ev),imag(ev),'s','magenta',...
              'LineWidth',1.5)
hold on;
scatter(real(ev1),imag(ev1),'s','black',...
              'LineWidth',1.5)
legend('Stab_Axi_Complex.edp, nev=20','Stab_Axi_Complex.edp, nev=1','Stab_Axi_Complex_m0.edp, nev=20','Stab_Axi_Complex_m0.edp, nev=1');

