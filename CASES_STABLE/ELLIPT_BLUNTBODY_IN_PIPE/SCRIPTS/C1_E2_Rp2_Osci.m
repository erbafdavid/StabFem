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

plot(MM(find(MM(:,1)==2),4),MM(find(MM(:,1)==2),6),'ro')
hold on


%% Deuxième couple

plot(MM2(find(MM2(:,1)==4),4),MM2(find(MM2(:,1)==4),6),'r+')


%% Titre et légende%

xlabel('Rp')
ylabel('\sigma_{i}')
axis([0 11 0 2])


%% Interpolation

x = MM(find(MM(:,1)==2),4);
y = MM(find(MM(:,1)==2),6);
xx = 1:0.1:6;
yy = spline(x,y,xx);
plot(xx,yy,'r')


x = MM2(find(MM2(:,1)==4),4);
y = MM2(find(MM2(:,1)==4),6);
xx = 1:0.1:6;
yy = spline(x,y,xx);
plot(xx,yy,'r')


legend('Oscillation rate M_{I1}','Oscillation rate M_{I2}')




hold off
