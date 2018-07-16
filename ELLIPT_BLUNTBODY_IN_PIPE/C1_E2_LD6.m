clear all

%Mes données%

M1_1000=load('DATA_THRESHOLDS/dataC1_E2_Rp1000LD600.txt');
M1_700=load('DATA_THRESHOLDS/dataC1_E2_Rp700LD600.txt');
M1_500=load('DATA_THRESHOLDS/dataC1_E2_Rp500LD600.txt');
M1_300=load('DATA_THRESHOLDS/dataC1_E2_Rp300LD600.txt');

M1_200=load('DATA_THRESHOLDS/dataC1_E2_Rp200LD600(1).txt');
M1_175=load('DATA_THRESHOLDS/dataC1_E2_Rp175LD600(1).txt');
M1_125=load('DATA_THRESHOLDS/dataC1_E2_Rp125LD600(1).txt');
M1_115=load('DATA_THRESHOLDS/dataC1_E2_Rp115LD600(1).txt');
M1_100=load('DATA_THRESHOLDS/dataC1_E2_Rp100LD600(1).txt');


M2_200=load('DATA_THRESHOLDS/dataC1_E2_Rp200LD600(2).txt');
M2_175=load('DATA_THRESHOLDS/dataC1_E2_Rp175LD600(2).txt');
M2_125=load('DATA_THRESHOLDS/dataC1_E2_Rp125LD600(2).txt');
M2_115=load('DATA_THRESHOLDS/dataC1_E2_Rp115LD600(2).txt');
M2_100=load('DATA_THRESHOLDS/dataC1_E2_Rp100LD600(2).txt');

MM=[M1_1000;M1_700;M1_500;M1_300;M1_200;M1_175;M1_125;M1_115;M1_100];
MM2=[M2_200;M2_175;M2_125;M2_115;M2_100];

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
axis([0 11 0 1500])


%% Interpolation

x = MM(find(MM(:,1)==2),3);
y = MM(find(MM(:,1)==2),5);
xx = 1:0.1:10;
yy = spline(x,y,xx);
plot(xx,yy,'r')

x = MM(find(MM(:,1)==1),3);
y = MM(find(MM(:,1)==1),5);
xx = 1:0.1:10;
yy = spline(x,y,xx);
plot(xx,yy,'b')


x = MM2(find(MM2(:,1)==4),3);
y = MM2(find(MM2(:,1)==4),5);
xx = 1:0.1:2;
yy = spline(x,y,xx);
plot(xx,yy,'r')


x = MM2(find(MM2(:,1)==3),3);
y = MM2(find(MM2(:,1)==3),5);
xx = 1:0.1:2;
yy = spline(x,y,xx);
plot(xx,yy,'b')

legend('Global stability M_{S1}','Global stability M_{I1}','Global stability M_{S2}','Global stability M_{I2}')

%% Troisième



hold off
