clear all

%Mes données%


M1_600=load('dataC1_E2_Rp200LD600(1).txt');
M1_400=load('dataC1_E2_Rp200LD400(1).txt');
M1_300=load('dataC1_E2_Rp200LD300(1).txt');
M1_200=load('dataC1_E2_Rp200LD200(1).txt');
M1_104=load('dataC1_E2_Rp200LD104(1).txt');


M2_600=load('dataC1_E2_Rp200LD600(2).txt');
M2_400=load('dataC1_E2_Rp200LD400(2).txt');
M2_300=load('dataC1_E2_Rp200LD300(2).txt');
M2_200=load('dataC1_E2_Rp200LD200(2).txt');
M2_104=load('dataC1_E2_Rp200LD104(2).txt');


MM=[M1_600;M1_400;M1_300;M1_200;M1_104];
MM2=[M2_600;M2_400;M2_300;M2_200;M2_104];

%% Premier couple

plot(MM(find(MM(:,1)==2),4),MM(find(MM(:,1)==2),5),'ro')
hold on
plot(MM(find(MM(:,1)==1),4),MM(find(MM(:,1)==1),5),'bv')


%% Deuxième couple

plot(MM2(find(MM2(:,1)==4),4),MM2(find(MM2(:,1)==4),5),'r+')
hold on
plot(MM2(find(MM2(:,1)==3),4),MM2(find(MM2(:,1)==3),5),'bx')


%% Titre et légende%

title('Dependance of the critical Reynolds numbers on Rp')
xlabel('Rp')
ylabel('Re')
axis([0 11 0 1500])


%% Interpolation

x = MM(find(MM(:,1)==2),4);
y = MM(find(MM(:,1)==2),5);
xx = 1:0.1:7;
yy = spline(x,y,xx);
plot(xx,yy,'r')

x = MM(find(MM(:,1)==1),4);
y = MM(find(MM(:,1)==1),5);
xx = 1:0.1:7;
yy = spline(x,y,xx);
plot(xx,yy,'b')


x = MM2(find(MM2(:,1)==4),4);
y = MM2(find(MM2(:,1)==4),5);
xx = 1:0.1:7;
yy = spline(x,y,xx);
plot(xx,yy,'r')


x = MM2(find(MM2(:,1)==3),4);
y = MM2(find(MM2(:,1)==3),5);
xx = 1:0.1:7;
yy = spline(x,y,xx);
plot(xx,yy,'b')

legend('Global stability M_{S1}','Global stability M_{I1}','Global stability M_{S2}','Global stability M_{I2}')

%% Troisième



hold off
