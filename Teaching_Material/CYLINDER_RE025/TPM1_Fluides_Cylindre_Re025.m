
clear all;
close all;
run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
system('mkdir FIGURES');

%% build mesh
bf=SF_Init('Mesh_Cylinder.edp',[-40 80 40]);

%% Compute steady soution for Re = 0.25, 5, 10, 20, 40
bf=SF_BaseFlow(bf,'Re',0.25);
bf=SF_Adapt(bf);
bf025 = bf;

bf=SF_BaseFlow(bf,'Re',5);
bf=SF_Adapt(bf);
bf5 = bf;


bf=SF_BaseFlow(bf,'Re',10);
bf=SF_Adapt(bf);
bf10 = bf;

bf=SF_BaseFlow(bf,'Re',20);
bf=SF_Adapt(bf);
bf20 = bf;


bf=SF_BaseFlow(bf,'Re',20);
bf=SF_Adapt(bf);
bf40 = bf;


%% plot pesh
figure();SF_Plot(bf,'mesh','title','mesh');


%% plot Ux, Uy, omega, P
figure();
suptitle('Flow for Re = 0.25');
subplot(2,2,1); SF_Plot(bf025,'ux','Contour','on','xlim',[-1.5 4.5],'ylim',[0 3],'title','u_x');
subplot(2,2,2); SF_Plot(bf025,'psi','Contour','on','xlim',[-1.5 4.5],'ylim',[0 3],'title','\psi','title','\psi','colorrange','cropminmax');
subplot(2,2,3); SF_Plot(bf025,'vort','Contour','on','xlim',[-1.5 4.5],'ylim',[0 3],'title','\omega');
subplot(2,2,4); SF_Plot(bf025,'p','Contour','on','xlim',[-1.5 4.5],'ylim',[0 3],'title','p');


%% Velocity along a vertical line 
figure;
Yvert = [0.5:.01:5]; 
Uvert025 = SF_ExtractData(bf025,'ux',0,Yvert);
Uvert5 = SF_ExtractData(bf5,'ux',0,Yvert);
Uvert10 = SF_ExtractData(bf10,'ux',0,Yvert);
Uvert20 = SF_ExtractData(bf20,'ux',0,Yvert);
Uvert40 = SF_ExtractData(bf40,'ux',0,Yvert);


plot(Uvert025,Yvert,'ro',Uvert5,Yvert,'mo-',Uvert10,Yvert,'bo-',Uvert20,Yvert,'go-',Uvert40,Yvert,'ko-');
xlabel('U'); ylabel('x'); title('Velocity U(0,y) along vertical line');
legend('Re=0.25','Re=5','Re=10','Re=20','Re=40');

%% pressure along the surface
figure;
theta = linspace(0,pi,200)
Ycircle = 0.51*sin(theta); Xcircle = 0.51*cos(theta); 
Ucirc025 = SF_ExtractData(bf025,'ux',Xcircle,Ycircle);
Ucirc5 = SF_ExtractData(bf5,'ux',Xcircle,Ycircle);
Ucirc10 = SF_ExtractData(bf10,'ux',Xcircle,Ycircle);
Ucirc20 = SF_ExtractData(bf20,'ux',Xcircle,Ycircle);
Ucirc40 = SF_ExtractData(bf40,'ux',Xcircle,Ycircle);

plot(theta,Ucirc025,'ro',theta,Ucirc5,'mo-',theta,Ucirc10,'bo-',theta,Ucirc20,'go-',theta,Ucirc40,'ko-');
xlabel('\theta'); ylabel('p'); title('pressure P(r=R,theta) along the surface');
legend('Re=0.25','Re=5','Re=10','Re=20','Re=40');


