function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the acoustic forced flow in a open pipe  

%
% USAGE : 
% autorun -> automatic check (non-regression test). 
% Result "value" is the number of unsuccessful tests
% autorun(1) -> produces the figures (in present case not yet any figures)

if(nargin==0) 
    isfigures=0; verbosity=0;
end;
format long;
value = 0;

run('../../SOURCES_MATLAB/SF_Start.m');verbosity=10;
myrm('WORK/*')
myrm('WORK/*/*')

% Latex plots 
% In case you do not have installed latex remove these latex
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');



ffmesh = SF_Mesh('Mesh_1.edp');
Forced = SF_LinearForced(ffmesh,1,'BC','SOMMERFELD');
ffmesh = SF_Adapt(ffmesh,Forced,'Hmax',1); % Adaptation du maillage
 
IMPPML = SF_LinearForced(ffmesh,[0.1:.1:1],'BC','PML','plot','no');

Zref = 0.3886 - 0.4582i;
Zcomp = IMPPML.Z(10)
disp('##### autorun test 1 : impedance');
error1 = abs(Zcomp/Zref-1)
if(error1>1e-3) 
    value = value+1 
end

if(isfigures>0)

Forced = SF_LinearForced(ffmesh,1,'BC','SOMMERFELD');

figure();
SF_Plot(Forced,'u','boundary','on','colormap','redblue');
figure();
SF_Plot(Forced,'p','boundary','on','colormap','redblue');

figure('DefaultAxesFontSize',18);
SF_Plot(Forced,'mesh');
hold on;SF_Plot(Forced,'u','mesh','off','boundary','on','colormap','redblue',...
                'colorbar','northoutside','cbtitle','u''_x','symmetry','YM'); % symmetry = XM means mirror about X-axis
end

end

%IMPPML = SF_LinearForced(ffmesh,[0.01:.01:2],'BC','PML','plot','no');
%IMPCM = SF_LinearForced(ffmesh,[0.01:.01:2],'BC','CM','plot','no');
%IMP = SF_LinearForced(ffmesh,[0.01:.01:2],'BC','SOMMERFELD','plot','no');
% 
% % trace de Z(k) parties reelles et imaginaires
% figure(2);
% plot(IMP.omega,real(IMP.Z),'b',IMP.omega,imag(IMP.Z),'b--','DisplayName','Sommerfeld');
% hold on;
% plot(IMPCM.omega,real(IMPCM.Z),'r',IMPCM.omega,imag(IMPCM.Z),'r--','DisplayName','CM');
% plot(IMPPML.omega,real(IMPPML.Z),'k',IMPPML.omega,imag(IMPPML.Z),'k--','DisplayName','PML');
% title(['Impedance $Z_r$ and $Z_i$'],'Interpreter','latex','FontSize', 30)
% xlabel('$k$','Interpreter','latex','FontSize', 30);
% ylabel('$Z_r,Z_i$','Interpreter','latex','FontSize', 30);
% leg=legend('Sommerfeld','CM','PML');
% leg.FontSize = 20;
% set(findall(gca, 'Type', 'Line'),'LineWidth',2);
% pause(0.1);
% % trace de |Z(k)| en semilog
% figure(3);
% semilogy(IMP.omega,abs(IMP.Z),'b--','DisplayName','CM');
% hold on;
% semilogy(IMPCM.omega,abs(IMPCM.Z),'r--','DisplayName','CM');
% semilogy(IMPPML.omega,abs(IMPPML.Z),'k--','DisplayName','CM');
% xlabel('b'); ylabel('|Z|');
% xlabel('$k$','Interpreter','latex','FontSize', 30);
% ylabel('$|Z|$','Interpreter','latex','FontSize', 30);
% title(['Impedance $|Z|$'],'Interpreter','latex','FontSize', 30)
% leg=legend('Sommerfeld','CM','PML');
% leg.FontSize = 20;
% set(findall(gca, 'Type', 'Line'),'LineWidth',2);
% 
% pause(0.1);
% 
% figure(4);
% semilogy(IMP.omega,IMP.R,'b--','DisplayName','Sommerfeld');
% hold on;
% semilogy(IMPCM.omega,IMPCM.R,'r--','DisplayName','CM');
% semilogy(IMPPML.omega,IMPPML.R,'k--','DisplayName','PML');
% xlabel('$k$','Interpreter','latex','FontSize', 30);
% ylabel('$R_i$','Interpreter','latex','FontSize', 30);
% title(['Reflection coefficient'],'Interpreter','latex','FontSize', 30)
% leg = legend('Sommerfeld','CM','PML');
% leg.FontSize = 20;
% set(findall(gca, 'Type', 'Line'),'LineWidth',2);
% % 
% % k = [0.01:0.01:2.0];
% % Z0 = 1/(2*pi);
% % R = 1;
% % L = 10;
% % ZL = Z0*(k.^2*R^2/4 + 1i*k*0.35*R);
% % Zin = Z0*(ZL.*cos(k*L)+1i*Z0*sin(k*L))./(1i*ZL.*sin(k*L)+Z0*cos(k*L))
% % plot(k,-real(Zin),'k',k, -imag(Zin), 'k--');
% % hold on;
% % plot(IMP.k,real(IMP.Z),'b',IMP.k,imag(IMP.Z),'b--','DisplayName','Sommerfeld');
% % 
% % plot(k,real(Zin),'k',IMPPML.k,real(IMPPML.Z),'b');
% % plot(k,-imag(Zin),'k',IMPCM.k,imag(IMPML.Z),'b');
