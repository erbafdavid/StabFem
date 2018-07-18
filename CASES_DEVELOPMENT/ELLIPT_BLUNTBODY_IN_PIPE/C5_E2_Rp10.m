clear all

%Mes données%

C6=load('DATA_THRESHOLDS/dataC5_E2_Rp1000LD600.txt');
C4=load('DATA_THRESHOLDS/dataC5_E2_Rp1000LD400.txt');
C3=load('DATA_THRESHOLDS/dataC5_E2_Rp1000LD300.txt');
C2=load('DATA_THRESHOLDS/dataC5_E2_Rp1000LD200.txt');
C1=load('DATA_THRESHOLDS/dataC5_E2_Rp1000LD104.txt');

MM=[C1;C2;C3;C4;C6];


plot(MM(find(MM(:,1)==2),4),MM(find(MM(:,1)==2),5),'ro')


hold on

plot(MM(find(MM(:,1)==1),4),MM(find(MM(:,1)==1),5),'bv')


%Jimenez 3D%

JIMENEZ_X=[1 2];
JIMENEZ_RECS=[215 319];
JIMENEZ_RECI=[254 413];

plot(JIMENEZ_X,JIMENEZ_RECI,'k+')
plot(JIMENEZ_X,JIMENEZ_RECS,'ks')



%Jimenez 2D


J_CI=load('DATA_THRESHOLDS/Jimenez_Globalstability_CI.txt');

x = J_CI(:,1);
y = J_CI(:,2);
xx = 1:0.1:9;
yy = spline(x,y,xx);
plot(xx,yy,'k:')

J_CS=load('DATA_THRESHOLDS/Jimenez_Globalstability_CS.txt');

x = J_CS(:,1);
y = J_CS(:,2);
xx = 1:0.1:9;
yy = spline(x,y,xx);
plot(xx,yy,'k--')


x = MM(find(MM(:,1)==2),4);
y = MM(find(MM(:,1)==2),5);
xx = 1:0.1:6;
yy = spline(x,y,xx);
plot(xx,yy,'r')


x = MM(find(MM(:,1)==1),4);
y = MM(find(MM(:,1)==1),5);
xx = 1:0.1:6;
yy = spline(x,y,xx);
plot(xx,yy,'b')

%Titre et légende%
title('Dependance of the critical Reynolds numbers on L/D')
xlabel('L/D')
ylabel('Re')
axis([0 11 0 1500])
legend('Global stability Re_{CI}','Global stability Re_{CS}','Jimenez Numerical simulations Re_{CI}^{3D}','Jimenez Numerical simulations Re_{CS}^{3D}','Jimenez Global stability Re_{CI}^{GLS}','Jimenez Global stability Re_{CS}^{GLS}')


hold off
