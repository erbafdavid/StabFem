%  Instability of the wake of a cylinder with STABFEM  
%
%  this scripts performs the following calculations :
%  3/ Stability curves St(Re) and sigma(Re) for Re = [40-100]

clear all;
% close all;
run('../../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;

% parameters for mesh creation 
% Outer Domain 
xinfm=-40.; xinfv=80.; yinf=40.;
% Inner domain
x1m=-2.5; x1v=10.; y1=2.5;
% Middle domain
x2m=-10.;x2v=30.;y2=10;
% Sponge extension
ls=300.0; 
% Refinement parameters
n=1.5; % Vertical density of the outer domain
ncil=100; % Refinement density around the cylinder
n1=7; % Density in the inner domain
n2=4; % Density in the middle domain
ns=1; % Density in the outer domain
nsponge=.15; % density in the sponge region


bf = SF_Init('Mesh.edp',[xinfm,xinfv,yinf,x1m,x1v,y1,x2m,x2v,y2,ls,n,ncil,n1,n2,ns,nsponge]);
% LOOP OVER RE FOR BASEFLOW + EIGENMODE
% LOOP OVER RE FOR BASEFLOW + EIGENMODE
Re_LIN = [46.5 : 3: 100.5];
Ma_Range = [0.05]
Ma_Range2 = [0.1:0.1:0.6]
Ma_LIN = [Ma_Range2];
Fx_LIN = [[]]; Lx_LIN = [[]];lambda_LIN=[[]];
Omega_c = [0.7295, 0.7291];
sigma_c = [-0.01, -0.01];
sizeM = size(Ma_LIN)
sizeM = sizeM(2)
sizeRe = size(Re_LIN)
sizeRe = sizeRe(2)
for index_i = [2:sizeM]
    Ma = Ma_LIN(index_i)
    bf=SF_BaseFlow(bf,'Re',46.5,'Mach',Ma,'ncores',1,'type','NEW');
    lambda = sigma_c(index_i+1)+Omega_c(index_i+1)*1i;
    [ev,em] = SF_Stability(bf,'shift',lambda,'nev',1,'sym','A','Ma',Ma);
    sigma_c(index_i+1) = real(ev);
    Omega_c(index_i+1) = imag(ev);
    Omega_c(index_i+2) = 2*Omega_c(index_i+1) - Omega_c(index_i);
    sigma_c(index_i+2) = 2*sigma_c(index_i+1) - sigma_c(index_i);
    lambda = ev;
    lambdaPrev = lambda;
    for j = [1:sizeRe]
        Re = Re_LIN(j)
        bf = SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
        Fx_LIN(index_i,j) = bf.Fx;
        Lx_LIN(index_i,j) = bf.Lx;
        lambda = 2*lambda - lambdaPrev; 
        [ev,em] = SF_Stability(bf,'nev',1,'shift',lambda,'sym','A','Ma',Ma);
        lambda = ev;
        if(j == 1)
            lambdaPrev = lambda-0.01-0.004i;
        else
            lambdaPrev = lambda;
        end
        lambda_LIN(index_i,j) = ev;
    end  
end
completed_lambda = 1;
save('./WORK/CylinderLinearSponge.mat')


save('./WORK/CylinderLinearSponge.mat');

figure(21);hold on;
Re_LIN_oldS = [46.5:3:100.5];
plot(Re_LIN_oldS,imag(lambda_LINS(1,1:19))/(2*pi),'r--','LineWidth',2);hold on;
plot(Re_LIN_oldS,imag(lambda_LINS(2,1:19))/(2*pi),'b--','LineWidth',2);hold on;
plot(Re_LINS,imag(lambda_LINS(3,:))/(2*pi),'k--','LineWidth',2);hold on;
plot(Re_LINS,imag(lambda_LINS(4,:))/(2*pi),'g--','LineWidth',2);hold on;
plot(Re_LINS,imag(lambda_LINS(5,:))/(2*pi),'y--','LineWidth',2);hold on;

figure(21);hold on;
plot(Re_LIN,imag(lambda_LIN(2,:))/(2*pi),'r-.','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LIN(3,:))/(2*pi),'b-.','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LIN(4,:))/(2*pi),'k-.','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LIN(5,:))/(2*pi),'g-.','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LIN(6,:))/(2*pi),'y-.','LineWidth',2);hold on;

plot(Re_LIN,imag(lambda_LINS(1,:))/(2*pi),'r-','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LINS(2,:))/(2*pi),'b-','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LINS(3,:))/(2*pi),'k-','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LINS(4,:))/(2*pi),'g-','LineWidth',2);hold on;
plot(Re_LIN,imag(lambda_LINS(5,:))/(2*pi),'y-','LineWidth',2);hold on;


figure();
plot(Re_LIN,real(lambda_LIN(1,:)),'r-','LineWidth',2);hold on;
plot(Re_LIN,real(lambda_LIN(2,:)),'b-','LineWidth',2);hold on;
plot(Re_LIN(1:end),real(lambda_LIN(3,1:end)),'k-','LineWidth',2);hold on;
plot(Re_LIN,real(lambda_LIN(4,:)),'g-','LineWidth',2);hold on;
plot(Re_LIN,real(lambda_LIN(5,:)),'y-','LineWidth',2);hold on;

