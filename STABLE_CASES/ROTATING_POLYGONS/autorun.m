function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the case ROTATING_POLYGONS
%
% USAGE : 
% autorun(0) -> automatic check
% autorun(1) -> produces the figures used for the manual
%%
close all;
run('../../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';
verbosity = 10;

if(nargin==0)
    isfigures=0; verbosity=0;
end;


%% CHAPTER 0 : creation of initial mesh 
a=.3;
xi = .25;
rhog = 1;
R = 1;
gamma = 0;
GammaBAR = xi*sqrt(2*rhog*a*R^2/(R^2-xi^2-2*xi^2*log(R/xi)));

density=60;

ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);


evm3_REF =  [2.8333, 3.7210, 4.2695 1.3374] % => Values from Mougel et al Paper 

% CHAPTER 1 : Eigenvalue computation for m=3

%%% warning : in Mougel we have modal dependance with the form exp( i (m theta - omega t) )
%%% and omega is negative (real for pure waves).
%%% here the form is exp ( lambda t + i m theta) . So omega corresponds to
%%% minus the imaginary par of our omega. This is why the guess is -3i and
%%% the eigenvalues are transposed for comparison.



[evm3,emm3] =  SF_Stability(ffmesh,'gamma',gamma,'rhog',1,'GammaBAR',GammaBAR,'nev',15,'m',3,'shift',-3i);
evm3FIG = 1i*evm3(1:4).' % transpose, not conjugate



%evm3_REF =  [ 2.858705i 3.558175i  4.30018i  1.236246i] => wrong ref ?


disp('### autorun test 1 : check eigenvalues for a=0.3, xi = 0.25, m=3');
error = sum(abs(evm3_REF-evm3FIG))

value = (error>1e-3)

if(isfigures)
verbosity=0;
    
% 1b : plots
figure(10);
subplot(2,2,1);
n=1;
plotFF(emm3(n),'phi.im','xlim',[0 1],'ylim',[0 .5]);hold on;plotFF_ETA(emm3(n),'Amp',0.05);
title(['Mode G0 : omega = ',num2str(-imag(evm3(n)))])
hold off;
subplot(2,2,2);
n=3;
plotFF(emm3(n),'phi.im','xlim',[0 1],'ylim',[0 .5]);hold on;plotFF_ETA(emm3(n),'Amp',0.05);
title(['Mode G1 : omega = ',num2str(-imag(evm3(n)))]);xlim([.2 1]);ylim([0 .5]);
hold off;
subplot(2,2,3);
n=2;
plotFF(emm3(n),'phi.im','xlim',[0.2 1],'ylim',[0 .5]);hold on;plotFF_ETA(emm3(n),'Amp',0.05);
hold on;
title(['Mode C0 : omega = ',num2str(-imag(evm3(n)))]);xlim([.2 1]);ylim([0 .5]);
hold off;
subplot(2,2,4)
n=4;
plotFF(emm3(n),'phi.im','xlim',[0 1],'ylim',[0 .5]);hold on;plotFF_ETA(emm3(n),'Amp',0.05);
title(['Mode C1 : omega = ',num2str(-imag(evm3(n)))]);xlim([.2 1]);ylim([0 .5]);
hold off;
hold off;
box on; pos = get(gcf,'Position'); pos(3)=pos(4)*1.5;set(gcf,'Position',pos); % resize aspect ratio
saveas(gca,'FIGURES/POLYGONS_modes',figureformat);

pause(0.1);

figure(22);hold on;
plot(0.25,real(evm3FIG(1)),'ro',0.25,real(evm3FIG(2)),'ro',0.25,real(evm3FIG(3)),'ro',0.25,real(evm3FIG(4)),'ro'); 


%% CHAPTER 2a : loop for xi = [.25 , .35] by increasing values
ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a .25 density]);
GammaBAR = xi*sqrt(2*rhog*a*R^2/(R^2-xi^2-2*xi^2*log(R/xi)));
evm3 =  SF_Stability(ffmesh,'gamma',gamma,'rhog',1,'GammaBAR',GammaBAR,'nev',20,'m',3,'shift',-3i); % without cont for initiating branches

tabxi = .25:.0025:.35;
tabEVm3 = [];
figure(20);
title('A few free surface shapes for potential vortex');hold on;

for xi = tabxi
    ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);
    GammaBAR = xi*sqrt(2*rhog*a*R^2/(R^2-xi^2-2*xi^2*log(R/xi)));
    figure(20);plot(ffmesh.xsurf,ffmesh.ysurf); hold on;pause(0.1);
    evm3 =  SF_Stability(ffmesh,'gamma',gamma,'rhog',1,'GammaBAR',GammaBAR,'nev',20,'m',3,'sort','cont','shift',-3i);
    tabEVm3 = [tabEVm3 evm3];    
end

% PLOTS
figure(22);hold on;
for num=1:8
    plot(tabxi,-imag(tabEVm3(num,:)),'b-','LineWidth',2);
end
figure(23);hold on;
for num=1:8
    plot(tabxi,real(tabEVm3(num,:)),'b-','LineWidth',2);
end

pause(0.1);


%% CHAPTER 2b : loop for xi = [.35 , .7] by increasing values

tabxi = .35:.025:.7;
tabEVm3 = [];
for xi = tabxi
    ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);
    GammaBAR = xi*sqrt(2*rhog*a*R^2/(R^2-xi^2-2*xi^2*log(R/xi)));
    figure(20);plot(ffmesh.xsurf,ffmesh.ysurf); hold on;pause(0.1);
    evm3 =  SF_Stability(ffmesh,'gamma',gamma,'rhog',1,'GammaBAR',GammaBAR,'nev',20,'m',3,'sort','cont','shift',-3i);
    tabEVm3 = [tabEVm3 evm3];    
end

% PLOTS
figure(22);hold on;
for num=1:8
    plot(tabxi,-imag(tabEVm3(num,:)),'b-','LineWidth',2);
end
figure(23);hold on;
for num=1:8
    plot(tabxi,real(tabEVm3(num,:)),'b-','LineWidth',2);
end


%% CHAPTER 2c : loop for xi = [.25 , .1] by decreasing values
ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a .25 density]);
evm3 =  SF_Stability(ffmesh,'gamma',gamma,'rhog',1,'GammaBAR',GammaBAR,'nev',20,'m',3,'shift',-3i); % without cont for initiating branches

tabxi = .25:-.001:.1;
tabEVm3 = [];
for xi = tabxi
    ffmesh = SF_Mesh('Mesh_PotentialVortex.edp','Params',[a xi density]);
    GammaBAR = xi*sqrt(2*rhog*a*R^2/(R^2-xi^2-2*xi^2*log(R/xi)));
    figure(20);
    plot(ffmesh.xsurf,ffmesh.ysurf); hold on;
    pause(0.1);
    evm3 =  SF_Stability(ffmesh,'gamma',gamma,'rhog',1,'GammaBAR',GammaBAR,'nev',20,'m',3,'sort','cont','shift',-3i);
    tabEVm3 = [tabEVm3 evm3];    
end

% PLOTS
figure(22);hold on;
for num=1:8
    plot(tabxi,-imag(tabEVm3(num,:)),'b','LineWidth',2);
end
title('\omega_r(\xi) for H/R = .3 and m=3');
xlabel('\xi');ylabel('\omega_r');
ylim([0 5]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/POLYGONS_omega',figureformat);

figure(23);hold on;
for num=1:8
    plot(tabxi,real(tabEVm3(num,:)),'b-','LineWidth',2);
end
title('\omega_i(\xi) for H/R = .3 and m=3');
xlabel('\xi');ylabel('\omega_r');
ylim([0  .1]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/POLYGONS_sigma',figureformat);

end 

end
