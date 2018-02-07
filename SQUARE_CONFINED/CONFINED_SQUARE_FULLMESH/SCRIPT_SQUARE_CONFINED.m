
run('../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures


BETA = 0.8;
baseflow=SF_Init('Mesh_SquareConfined.edp',[BETA -5 20]);
baseflow=SF_BaseFlow(baseflow,'Re',10);
baseflow=SF_Adapt(baseflow,'Hmax',.25);
baseflow=SF_BaseFlow(baseflow,'Re',50);
baseflow=SF_BaseFlow(baseflow,'Re',70);
baseflow=SF_Adapt(baseflow,'Hmax',.25);
baseflow=SF_BaseFlow(baseflow,'Re',100);
%baseflow=SF_BaseFlow(baseflow,'Re',120);
%baseflow=SF_BaseFlow(baseflow,'Re',150);
%baseflow=SF_Adapt(baseflow,'Hmax',.25);
%baseflow=SF_BaseFlow(baseflow,'Re',170);
%baseflow=SF_BaseFlow(baseflow,'Re',200);
%baseflow=SF_Adapt(baseflow,'Hmax',.25);
%baseflow=SF_Adapt(baseflow,'Hmax',.25);
%disp(' ');
% optional :
%disp('mesh adaptation to SENSITIVITY : ')
[ev,em] = SF_Stability(baseflow,'shift',0.04+0.76i,'nev',1,'type','S');
[baseflow,em]=SF_Adapt(baseflow,em,'Hmax',10);

% plot the base flow
plotFF(baseflow,'ux');
% or if you prefer tecplot:
exportFF_tecplot(baseflow,'bf_08_100.plt')

% compute and plot an eigenmode :
[ev,em] = SF_Stability(baseflow,'shift',3.69i,'nev',1,'type','D');
plotFF(em,'ux1');
% or if you prefer tecplot:
exportFF_tecplot(em,'ModeU_08_200.plt')

% unsteady branch

Re_LIN = [170 : 5: 250];
baseflow=SF_BaseFlow(baseflow,'Re',170);
[ev,em] = SF_Stability(baseflow,'shift',-.02+3.69i,'nev',1,'type','D');

lambda_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_LIN = [lambda_LIN ev];
    end    

figure(20);subplot(2,1,1);hold on;
plot(Re_LIN,real(lambda_LIN),'b+-');
plot(Re_LIN,0*Re_LIN,'k:');

figure(20);subplot(2,1,2);hold on;
plot(Re_LIN,imag(lambda_LIN),'b+-');


    


% branches in the vicinity of zero

Re_LIN = [170 : 5: 250];
baseflow=SF_BaseFlow(baseflow,'Re',170);
[ev,em] = SF_Stability(baseflow,'shift',-.02+0i,'nev',1,'type','D');

lambda_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',10,'shift',0);
        lambda_LIN = [lambda_LIN ev];
    end    

figure(20);subplot(2,1,1);hold on;
plot(Re_LIN,real(lambda_LIN(1,:)),'r+-');
plot(Re_LIN,real(lambda_LIN(2,:)),'g+-');
%plot(Re_LIN,real(lambda_LIN(3,:)),'m+-');

figure(20);subplot(2,1,2);hold on;
plot(Re_LIN,imag(lambda_LIN(1,:)),'r+-');
plot(Re_LIN,imag(lambda_LIN(2,:)),'g+-');
%plot(Re_LIN,imag(lambda_LIN(3,:)),'m+-');
pause(0.1);


% steady branch for Re<170

Re_LIN = [170 : -5: 100];
baseflow=SF_BaseFlow(baseflow,'Re',170);
[ev,em] = SF_Stability(baseflow,'shift',0.16+0i,'nev',1,'type','D');

lambda_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_LIN = [lambda_LIN ev];
    end    

figure(20);subplot(2,1,1);hold on;
plot(Re_LIN,real(lambda_LIN(1,:)),'r+-');
plot(Re_LIN,0*Re_LIN,'k:');

figure(20);subplot(2,1,2);hold on;
plot(Re_LIN,imag(lambda_LIN(1,:)),'r+-');



% Mise en forme finale de la figure

figure(20);subplot(2,1,1);
title(['Aspect ratio : ',num2str(BETA)]);
xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
box on; 
set(gca,'FontSize', 16);
figure(20);subplot(2,1,2);
xlabel('Re');ylabel('$\omega$','Interpreter','latex');
box on; 
set(gca,'FontSize', 16);
pause(0.1);
saveas(gca,'Square_08_stabbranches',figureformat);


