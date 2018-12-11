%% Acoustic field in a pipe with harmonic forcing at the bottom
%
%  This scripts demonstrates the efficiency of StabFem for a linear acoustics problem
%
%   Problem : find the velocity potential $\phi$ such as :
%
%  * $\Delta \phi + k^2 \phi = 0$
%  * $u_z = \partial_z \phi = 1$ along $\Gamma_{in}$
%  * Sommerfeld radiation condition on $\Gamma_{out}$ (PML is also available)
%  ( $k = \omega c_0$ is the acoustic wavenuber) 
%
% 
%  Variational formulation :
%
%  $$ \int \int_\Omega \left( \nabla \phi \cdot \nabla \phi^* + k^2 \phi \phi^*\right) dV 
%  + \int_{\Gamma_{in}} \phi^* dS
%  + \int_{\Gamma_{out}} (i k +1/R) \phi \phi^* dV
%  = 0 $$   


%% initialisation
clear all
%close all
run('../../SOURCES_MATLAB/SF_Start.m');
%set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
%set(groot, 'defaultLegendInterpreter','latex');


%% Chapter 1 : building an adapted mesh
ffmeshInit = SF_Mesh('Mesh_1.edp');
Forced = SF_LinearForced(ffmeshInit,'omega',1,'BC','SOMMERFELD');
ffmesh = SF_Adapt(ffmeshInit,Forced,'Hmax',1); % Adaptation du maillage


%% 
%plot the mesh :
figure;  SF_Plot(ffmeshInit,'symmetry','ym','boundary','on');
hold on; SF_Plot(ffmesh,'title','Mesh : Initial (left) and Adapted (right)','boundary','on');



%% Chapter 2 : Compute and plot the pressure fied with harmonic forcing at the bottom of the tube

omega = 1;
Forced = SF_LinearForced(ffmesh,'omega',omega,'BC','SOMMERFELD')

figure();
SF_Plot(Forced,'p','boundary','on','colormap','redblue','cbtitle','Re(p'')','title','Pressure : real (left) and imaginary (right) parts');
hold on;
SF_Plot(Forced,'p.im','boundary','on','colormap','redblue','symmetry','YM','cbtitle','Im(p'')');


%%
% Create a movie (animated gif) from this field

h = figure;
filename = 'html/AcousticTube.gif';
SF_Plot(Forced,'p','boundary','on','colormap','redblue','colorrange',[-1 1],...
        'symmetry','YS','cbtitle','p''','colorbar','eastoutside','bdlabels',[1 2 ],'bdcolors','k','Amp',1);
set(gca,'nextplot','replacechildren');
    for k = 1:20
       Amp = exp(-2*pi*1i*k/20);
       SF_Plot(Forced,'p','boundary','on','contour','on','clevels',[-2 :.5 :2],...
           'colormap','redblue','colorrange',[-1 1],...
           'symmetry','YS','cbtitle','p''','colorbar','eastoutside','bdlabels',[1 2 ],'bdcolors','k','Amp',Amp); 
      frame = getframe(h); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      if k == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
    end
 

%%
% Here is the movie
%
% <<AcousticTube.gif>>
%



%%
% Extract p and |u| along the symmetry axis
           
Xaxis = [-10 :.1 :10];
Uyaxis = SF_ExtractData(Forced,'uz',0,Xaxis);
Paxis = SF_ExtractData(Forced,'p',0,Xaxis);

%%
% Plot  p and |u| along the symmetry axis
figure();
plot(Xaxis,real(Uyaxis),Xaxis,imag(Uyaxis)); hold on;plot(Xaxis,real(Paxis),Xaxis,imag(Paxis));
xlabel('x');
legend('Re(u''_z)','Im(u''_z)','Re(p'')','Im(p'')');
pause(0.1);

%% Chapter 3 : loop over k to compute the impedance $Z(k)$ (using SOMMERFELD)

IMP = SF_LinearForced(ffmesh,[0.01:.01:2],'BC','SOMMERFELD','plot','no')

%% 
% Plot $Z(k)$ 
figure;
plot(IMP.omega,real(IMP.Z),'b',IMP.omega,imag(IMP.Z),'b--','DisplayName','Sommerfeld');
title(['Impedance $Z_r$ and $Z_i$'],'Interpreter','latex','FontSize', 30)
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$Z_r,Z_i$','Interpreter','latex','FontSize', 30);
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
pause(0.1);

%%
% plot in semilog
figure;
semilogy(IMP.omega,abs(IMP.Z),'b--','DisplayName','CM');
xlabel('b'); ylabel('|Z|');
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$|Z|$','Interpreter','latex','FontSize', 30);
title(['Impedance $|Z|$'],'Interpreter','latex','FontSize', 30)
leg.FontSize = 20;
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

pause(0.1);

%{
%% Chapter 4 : trying better kind of boundary conditions : PML, CM

IMPPML = SF_LinearForced(ffmesh,[0.01:.01:2],'BC','PML','plot','no');
IMPCM = SF_LinearForced(ffmesh,[0.01:.01:2],'BC','CM','plot','no');
IMP = SF_LinearForced(ffmesh,[0.01:.01:2],'BC','SOMMERFELD','plot','no');

%%
% Plot Z(k) real and imaginary parts
figure;
plot(IMP.omega,real(IMP.Z),'b',IMP.omega,imag(IMP.Z),'b--','DisplayName','Sommerfeld');
hold on;
plot(IMPCM.omega,real(IMPCM.Z),'r',IMPCM.omega,imag(IMPCM.Z),'r--','DisplayName','CM');
plot(IMPPML.omega,real(IMPPML.Z),'k',IMPPML.omega,imag(IMPPML.Z),'k--','DisplayName','PML');
title(['Impedance $Z_r$ and $Z_i$'],'Interpreter','latex','FontSize', 30)
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$Z_r,Z_i$','Interpreter','latex','FontSize', 30);
leg=legend('Sommerfeld','CM','PML');
leg.FontSize = 20;
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
pause(0.1);

%%
% Plot |Z(k)| in semilog

figure;
semilogy(IMP.omega,abs(IMP.Z),'b--','DisplayName','CM');
hold on;
semilogy(IMPCM.omega,abs(IMPCM.Z),'r--','DisplayName','CM');
semilogy(IMPPML.omega,abs(IMPPML.Z),'k--','DisplayName','CM');
xlabel('b'); ylabel('|Z|');
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$|Z|$','Interpreter','latex','FontSize', 30);
title(['Impedance $|Z|$'],'Interpreter','latex','FontSize', 30)
leg=legend('Sommerfeld','CM','PML');
leg.FontSize = 20;
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

pause(0.1);

%%
% plot reflection coefficient

figure;
semilogy(IMP.omega,IMP.R,'b--','DisplayName','Sommerfeld');
hold on;
semilogy(IMPCM.omega,IMPCM.R,'r--','DisplayName','CM');
semilogy(IMPPML.omega,IMPPML.R,'k--','DisplayName','PML');
xlabel('$k$','Interpreter','latex','FontSize', 30);
ylabel('$R_i$','Interpreter','latex','FontSize', 30);
title(['Reflection coefficient'],'Interpreter','latex','FontSize', 30)
leg = legend('Sommerfeld','CM','PML');
leg.FontSize = 20;
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

%}

% 
% k = [0.01:0.01:2.0];
% Z0 = 1/(2*pi);
% R = 1;
% L = 10;
% ZL = Z0*(k.^2*R^2/4 + 1i*k*0.35*R);
% Zin = Z0*(ZL.*cos(k*L)+1i*Z0*sin(k*L))./(1i*ZL.*sin(k*L)+Z0*cos(k*L))
% plot(k,-real(Zin),'k',k, -imag(Zin), 'k--');
% hold on;
% plot(IMP.k,real(IMP.Z),'b',IMP.k,imag(IMP.Z),'b--','DisplayName','Sommerfeld');
% 
% plot(k,real(Zin),'k',IMPPML.k,real(IMPPML.Z),'b');
% plot(k,-imag(Zin),'k',IMPCM.k,imag(IMPML.Z),'b');

