clear all

%Mes données%



M1_200=load('DATA_THRESHOLDS/dataC1_E2_Rp200LD600(1).txt');
M1_175=load('DATA_THRESHOLDS/dataC1_E2_Rp175LD600(1).txt');
M1_125=load('DATA_THRESHOLDS/dataC1_E2_Rp125LD600(1).txt');
M1_120=load('DATA_THRESHOLDS/dataC1_E2_Rp120LD600(1).txt');
M1_115=load('DATA_THRESHOLDS/dataC1_E2_Rp115LD600(1).txt');
M1_110=load('DATA_THRESHOLDS/dataC1_E2_Rp110LD600(1).txt');
M1_105=load('DATA_THRESHOLDS/dataC1_E2_Rp105LD600(1).txt');
M1_100=load('DATA_THRESHOLDS/dataC1_E2_Rp100LD600(1).txt');
M1_95=load('DATA_THRESHOLDS/dataC1_E2_Rp95LD600(1).txt');
M1_90=load('DATA_THRESHOLDS/dataC1_E2_Rp90LD600(1).txt');
M1_85=load('DATA_THRESHOLDS/dataC1_E2_Rp85LD600(1).txt');
M1_80=load('DATA_THRESHOLDS/dataC1_E2_Rp80LD600(1).txt');
M1_75=load('DATA_THRESHOLDS/dataC1_E2_Rp75LD600(1).txt');




M2_200=load('DATA_THRESHOLDS/dataC1_E2_Rp200LD600(2).txt');
M2_175=load('DATA_THRESHOLDS/dataC1_E2_Rp175LD600(2).txt');
M2_125=load('DATA_THRESHOLDS/dataC1_E2_Rp125LD600(2).txt');
M2_120=load('DATA_THRESHOLDS/dataC1_E2_Rp120LD600(2).txt');
M2_115=load('DATA_THRESHOLDS/dataC1_E2_Rp115LD600(2).txt');
M2_110=load('DATA_THRESHOLDS/dataC1_E2_Rp110LD600(2).txt');
M2_105=load('DATA_THRESHOLDS/dataC1_E2_Rp105LD600(2).txt');
M2_100=load('DATA_THRESHOLDS/dataC1_E2_Rp100LD600(2).txt');
M2_95=load('DATA_THRESHOLDS/dataC1_E2_Rp95LD600(2).txt');
M2_90=load('DATA_THRESHOLDS/dataC1_E2_Rp90LD600(2).txt');
M2_85=load('DATA_THRESHOLDS/dataC1_E2_Rp85LD600(2).txt');
M2_80=load('DATA_THRESHOLDS/dataC1_E2_Rp80LD600(2).txt');
M2_75=load('DATA_THRESHOLDS/dataC1_E2_Rp75LD600(2).txt');

MM=[M1_200;M1_175;M1_125;M1_120;M1_115;M1_110;M1_105;M1_100;M1_95;M1_90;M1_85;M1_80;M1_75];
MM2=[M2_200;M2_175;M2_125;M2_120;M2_115;M2_110;M2_105;M2_100;M2_95;M2_90;M2_85;M2_80;M2_75];

%% Premier couple

plot(MM(find(MM(:,1)==2),3),MM(find(MM(:,1)==2),5),'ro')
hold on
plot(MM(find(MM(:,1)==1),3),MM(find(MM(:,1)==1),5),'bv')


%% Deuxième couple

plot(MM2(find(MM2(:,1)==4),3),MM2(find(MM2(:,1)==4),5),'r+')
hold on
plot(MM2(find(MM2(:,1)==3),3),MM2(find(MM2(:,1)==3),5),'bx')


%% Titre et légende%

title('Dependance of the critical Reynolds numbers on Rp')
xlabel('Rp')
ylabel('Re')
axis([0 3 0 1300])


%% Interpolation

x = MM(find(MM(:,1)==2),3);
y = MM(find(MM(:,1)==2),5);
xx = 0.75:0.01:2;
yy = spline(x,y,xx);
plot(xx,yy,'r')

x = MM(find(MM(:,1)==1),3);
y = MM(find(MM(:,1)==1),5);
xx = 0.75:0.01:2;
yy = spline(x,y,xx);
plot(xx,yy,'b')


x = MM2(find(MM2(:,1)==4),3);
y = MM2(find(MM2(:,1)==4),5);
xx = 0.75:0.01:2;
yy = spline(x,y,xx);
plot(xx,yy,'r')


x = MM2(find(MM2(:,1)==3),3);
y = MM2(find(MM2(:,1)==3),5);
xx = 0.75:0.01:2;
yy = spline(x,y,xx);
plot(xx,yy,'b')

legend('Global stability M_{S1}','Global stability M_{I1}','Global stability M_{S2}','Global stability M_{I2}')

%% Troisième



hold off
