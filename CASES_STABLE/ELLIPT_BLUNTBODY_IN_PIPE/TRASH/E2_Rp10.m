clear all

%Mes données%

dataE2_Rp10LD6=load('dataE2_Rp10LD6.txt');
dataE2_Rp10LD4=load('dataE2_Rp10LD4.txt');
dataE2_Rp10LD3=load('dataE2_Rp10LD3.txt');
dataE2_Rp10LD2=load('dataE2_Rp10LD2.txt');
dataE2_Rp10LD1=load('dataE2_Rp10LD1.txt');


MM=[dataE2_Rp10LD1;dataE2_Rp10LD2;dataE2_Rp10LD3;dataE2_Rp10LD4;dataE2_Rp10LD6];

plot([0 1 2 3 4 5 6 7 8 9 10],MM(find(MM(:,1)==2),4),'ro')

hold on

plot(MM(find(MM(:,1)==1),3),MM(find(MM(:,1)==1),4),'bv')


%Jimenez 3D%

JIMENEZ_X=[1 2];
JIMENEZ_RECS=[215 319];
JIMENEZ_RECI=[254 413];

plot(JIMENEZ_X,JIMENEZ_RECI,'k+')
plot(JIMENEZ_X,JIMENEZ_RECS,'ks')



%Jimenez 2D

J_CS=load('Jimenez_Globalstability_CS.txt');

x = J_CS(:,1);
y = J_CS(:,2);
xx = 1:0.1:9;
yy = spline(x,y,xx);
plot(xx,yy,'k')

J_CI=load('Jimenez_Globalstability_CI.txt');

x = J_CI(:,1);
y = J_CI(:,2);
xx = 1:0.1:9;
yy = spline(x,y,xx);
plot(xx,yy,'k')

x = MM(find(MM(:,1)==2),3);
y = MM(find(MM(:,1)==2),4);
xx = 1:0.1:6;
yy = spline(x,y,xx);
plot(xx,yy,'r')


x = MM(find(MM(:,1)==1),3);
y = MM(find(MM(:,1)==1),4);
xx = 1:0.1:6;
yy = spline(x,y,xx);
plot(xx,yy,'b')


%Titre et légende%
title('Dependance of the critical Reynolds numbers on L/D')
xlabel('L/D')
ylabel('Re')
axis([0 11 0 1500])
legend('Global stability Re_{CI}','Global stability Re_{CS}','Jimenez Numerical simulations Re_{CI}^{3D}','Jimenez Numerical simulations Re_{CS}^{3D}','Jimenez Global stability Re_{CS}^{GLS}','Jimenez Global stability Re_{CI}^{GLS}')

hold off
